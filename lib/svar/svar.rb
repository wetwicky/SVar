@mutex#
# Module pour mettre en oeuvre des variables synchronisees, telles que
# decrites dans l'enonce du devoir 2, INF5171-20, automne 2017.
#
# @author Guy Tremblay
#
module SVar
  Thread.abort_on_exception = true

  # Les differents types de variables pouvant etre creees.
  SVAR_TYPES = [:read_only, :write_once, :mutable]

  # Les differents modes d'initialisation.
  MODES_INIT = [:immediate, :async, :frozen]

  # Les differents etats d'une variable.
  SVAR_STATE = [:in_evaluation, :frozen, :empty, :full]

  ######################################################################
  # Methodes de fabrication.
  ######################################################################

  #
  # Methode de fabrication pour une variable synchronisee.
  #
  # @param [nil, SVAR_TYPES] type Type (sorte) de variable a creer
  # @param [nil, MODES_INIT] init Mode d'initialisation de la variable
  # @return [SVar, SVarWritable, SVarMutable]
  #
  # @yieldparam [void]
  # @yieldreturn [Object] La valeur a affecter a la variable
  #
  # @require type == :read_only => block_given?
  #
  # @ensure type == :read_only && init == :immediate => full?
  # @ensure type == :read_only && init == :frozen => state == :frozen
  # @ensure init == :async => state == :in_evaluation || state == :full
  # @ensure !block_given? => empty?
  #
  def self.new( type = :write_once, init = :async, &block )
    Debug.debug "#{self}.new( #{type}, #{init}, #{block} )", 1

    DBC.check_value( type, SVAR_TYPES,
                     "Dans #{self}.new: Argument type incorrect = #{type.inspect}" )
    DBC.check_value( init, MODES_INIT,
                     "Dans #{self}.new: Argument init incorrect = #{init.inspect}" )

    case type
    when :read_only
      DBC.require( block, "Un bloc doit etre specifie pour une variable :read_only" )
      SVar.new( type, init, &block )
    when :write_once
      SVarWritable.new( type, init, &block )
    when :mutable
      SVarMutable.new( type, init, &block )
    else
      DBC.assert( false, "*** Cas impossible dans case de #{self}.new!?" )
    end
  end

  #
  # Cree une variable synchronisee combinant une serie d'autres
  # valeurs synchronisees.  Son contenu ne devient disponible que
  # lorsque les valeurs de toutes les variables recuees en argument
  # sont disponibles.
  #
  # @param [Array<SVar>] svars Les variables a combiner
  # @return [SVarWritable]
  #
  # @require svars.size >= 1
  # @ensure toutes les svars sont evaluees et return.value est un
  #         tableau de toutes ces valeurs
  #
  def self.all( *svars )
    DBC.require( svars.size >= 1, "*** Il doit y avoir au moins un argument" )

    # A COMPLETER.
  end

  #
  # Cree une variable synchronisee selectionnant une variable parmi
  # plusieurs recues en argument.  Son contenu devient disponible
  # *aussitot* que l'une des valeurs recuees devient disponible.
  #
  # @param [Array<SVar>] svars Les variables a combiner
  # @return [SVarWritable]
  #
  # @require svars.size >= 1
  # @ensure return.value est une des valeurs parmi svars.
  #
  def self.any( *svars )
    DBC.require( svars.size >= 1, "*** Il doit y avoir au moins un argument" )

    # A COMPLETER."
  end

  #
  # Classe pour variable synchronisee. Par defaut, si non
  # sous-classee, utilisable en mode lecture seulement.
  #
  class SVar
    #
    # Cree une nouvelle variable synchronisee.
    #
    # @param [SVAR_TYPES] type Type (sorte) de variable a creer
    #
    # @yieldparam [void]
    # @yieldreturn [Object] La valeur a affecter a la variable
    #
    # @ensure init == :immediate => state == :full
    # @ensure init == :async     => state == :in_evaluation || state == :full
    # @ensure init == :frozen => state == :frozen
    # @ensure block.nil? => state == :empty
    #
    def initialize( type, init, &block )
      Debug.debug "#{self}.initialize( #{type}, #{block} )", 1

      @type = type
      @value = nil
      @block = nil

      @mutex = Mutex.new
      @is_full = ConditionVariable.new

      if block
        case init
        when :immediate
          # Valeur obtenue immédiatement
          @mutex.synchronize do
            # Evaluation de la valeur
            @value = block.call
            @state = :full
            # On signal que la valeur de la var est disponible
            @is_full.signal
          end
        when :frozen
          # Valeur obtenue plus tard
          @mutex.synchronize do
            @state = :frozen
            # On stocke le block pour quand l'évaluation sera voulue
            @block = block
          end
        when :async
          # Valeur obtenue dès que possible
          @mutex.synchronize do
            # On change temporairment le status de la var en cours d'évaluation
            @state = :in_evaluation
            # On lance un thread qui va effectuer l'évaluation
            th = Thread.new {@value = @block.call}.start
            # On attend le resultat
            th.join
            @state = :full
            # On signal que la valeur de la var est disponible
            @is_full.signal
          end
        else
          DBC.assert( false, "Cas impossible: type = #{type}" )
        end
      else
        DBC.require( type == :write_once || type == :mutable,
                     "*** Si pas de bloc d'initialisation, alors doit etre :write_once ou :mutable" )
        # La variable est vide et attend de recevoir un bloc
        @mutex.synchronize do
          @state = :empty
        end
      end
    end

    #
    # Retourne l'etat courant.
    #
    # @return [SVAR_STATE]
    #
    def state
      @state
    end

    #
    # Indique si la variable ne peut qu'etre lue.
    #
    # @return [Bool]
    #
    def read_only?
      @type == :read_only
    end

    #
    # Indique si la variable peut etre ecrite.
    #
    # @return [Bool]
    #
    def writable?
      @type == :write_once || @type == :mutable
    end

    #
    # Indique si la variable peut etre modifiee, donc ecrite plusieurs
    # fois.
    #
    # @return [Bool]
    #
    def mutable?
      @type == :mutable
    end

    #
    # Indique si la variable est actuellement vide, donc pouvant etre
    # ecrite.
    #
    # @return [Bool]
    #
    def empty?
      @state == :empty
    end

    #
    # Indique si la variable est actuellement pleine, i.e.,
    # completement definie.
    #
    # @return [Bool]
    #
    def full?
      @state == :full
    end

    #
    # Retourne la valeur contenue dans la variable.
    #
    # @return [Object]
    #
    # @ensure L'appel est bloque si l'etat pas full?
    #
    def value
        eval if @state == :frozen
      @mutex.synchronize do
        @is_full.wait(@mutex) until full?
      end

      @value
    end


    #
    # Lance l'evaluation de la variable lorsque son contenu est
    # :frozen.
    #
    # @return [void]
    #
    # @require !empty?
    # @ensure Si la valeur n'est pas disponible et pas en evaluation,
    #         alors l'evaluation est lancee de facon *asynchrone*, et
    #         donc l'appel n'est pas bloque. Si l'evaluation est deja
    #         en cours ou completee, alors l'appel n'a aucun effet (no-op).
    #
    def eval
      @mutex.synchronize do
        if @state == :frozen
          @state = :in_evaluation
          @value = @block.call
          @state = :full
        end
      end

    end

    #
    # Cree une nouvelle variable synchronisee dont le contenu sera
    # defini a partir du resultat produit par l'evaluation de la
    # variable courante, lorsque disponible.
    #
    # @return [SVar]
    #
    # @yieldparam  [Object] value Valeur de la SVar courante
    # @yieldreturn [Object] La valeur pour la nouvelle variable creee par le then
    #
    # @ensure L'evaluation de la variable courante est lancee de facon
    #         *asynchrone*, si pas deja evaluee.
    #
    def then
      SVar.new( write_once, :async, yield(value))
    end
  end

  #
  # Sous-classe pour des variables synchronisees pouvant etre ecrites.
  #
  class SVarWritable < SVar
    #
    # Definit la valeur de la variable.
    #
    # @param [Object] v La nouvelle valeur
    # @return [Object] La valeur affectee
    #
    # @require empty?
    # @ensure full?
    #
    def value=( v )
      @value = v if empty?
    end
  end

  #
  # Sous-classe pour des variables synchronisees pouvant etre
  # modifiees.
  #
  class SVarMutable < SVarWritable
    #
    # Obtient et retire la valeur de la variable.
    #
    # @return [Object]
    #
    # @ensure Sera bloque jusqu'a ce que la variable devienne full? si
    #         elle ne l'est pas
    # @ensure empty?
    #
    def take
      @mutex.synchronize do
        @is_full.wait( @mutex ) until full?
        taken = @value
        @value = nil
        @state = :empty
      end

      taken
    end

    #
    # Modifie la valeur de la variable.
    #
    # @yieldparam [Object] value La valeur courante de la variable
    # @yieldreturn [Object] La nouvelle valeur de la variable
    #
    # @return [Object] La nouvelle valeur de la variable
    #
    # @ensure Sera bloque jusqu'a ce que la variable devienne full? si
    #         elle ne l'est pas
    # @ensure full?
    #
    def mutate!
      @mutex.synchronize do
        @is_full.wait( mutex ) until full?
        @value = yield
      end

      @value
    end
  end
end
