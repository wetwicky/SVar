###############################################################
# Constante a completer.
###############################################################

# Vous devez completer l'une ou l'autre des definitions de la
# constante CODES_PERMANENTS.

# Deux etudiants:
# Si vous etes deux etudiants: Indiquer vos codes permanents.
CODES_PERMANENTS='ABCD01020304,GHIJ11121314'


# Un etudiant:
# Si vous etes seul: Supprimer le diese en debut de ligne et
# indiquer votre code permanent (sans changer le nom de la variable).
#CODES_PERMANENTS='ABCD01020304'


###############################################################

require 'rake/clean'
require "rake/testtask"

###############################################################
# Cible pour le(s) test(s) en cours de developpement = wip
#       (WIP = Work In Progress)
###############################################################

wip = []


# Tache par defaut initial = tests pour svar_new
#
# A modifier pour, par defaut, traiter d'autres tests,
# en otant le "#" devant "#wip <<" et/ou en mettant un "#"
# devant le test complete.

# Tests unitaires.
wip << :svar_new
#wip << :svar_value
#wip << :svar_state
#wip << :svar_writable
#wip << :svar_mutable
#wip << :svar_frozen
#wip << :svar_eval
#wip << :svar_then
#wip << :svar_all_any

#wip << :debug # Pour deboger une suite de tests: voir plus bas.

# Tous les tests unitaires.
#wip = :tests

# Tests qui sont associes a des 'programmes' dans bin.
#wip << :fibo
#wip << :wavefront
#wip << :lazy_list
#wip << :graphe
#wip << :services

# Tous les programmes.
#wip = :programmes

task :default => wip


##################################################
# Les differents taches pour les tests.
##################################################

#
# Tache pour deboguer une suite de tests specifique, en utilisant le
# mode "verbose", ce qui permet de mieux identifier lequel parmi les
# tests ne fonctionne pas, notamment en cas de deadlock -- donc
# determiner a quel endroit ca bloque.
#
# Il suffit de modifier la variable suite_a_deboguer pour specifier la
# suite de test a tracer de facon plus detaillee.
#
task :debug do
  suite_a_deboguer = "svar_state_spec.rb"

  sh %{ruby -Ilib -Ispec spec/#{suite_a_deboguer}  --verbose}
end

# Methode auxilaiire pour definir un test a partir d'un fichier approprie.
def test_pour nom, description
  desc description
  task nom do
    sh %{rake tous_les_tests TEST=spec/#{nom.to_s}_spec.rb}
  end
end

# Les differents tests unitaires.
test_pour :svar_new, 'Tests pour new et state'
test_pour :svar_value, 'Tests pour value'
test_pour :svar_state, 'Tests plus detailles pour state'
test_pour :svar_writable, 'Tests pour les SVarWritable'
test_pour :svar_mutable, 'Tests pour les SVarMutable'
test_pour :svar_frozen, 'Tests pour evaluation paresseuse'
test_pour :svar_eval, 'Tests pour eval'
test_pour :svar_then, 'Tests pour le then'
test_pour :svar_all_any, 'Tests pout all et any'

# Les tests pour des 'programmes' dans bin utilisant des SVar.
test_pour :fibo, 'Tests pour calcul du N-ieme nombre de Fibonacci'
test_pour :wavefront, 'Tests pour wavefront simplifie'
test_pour :lazy_list, 'Tests pour listes paresseuses'
test_pour :graphe, 'Tests pour marquage de graphes'
test_pour :services, 'Tests pour services Web asynchrones'


##################################################
# Execution des tests.
##################################################

desc 'Tous les tests unitaires'
task :tests => :tests_unitaires

Rake::TestTask.new(:tests_unitaires) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList['spec/**/svar*_spec.rb']
end

desc 'Tous les tests avec des programmes'
task :programmes => :tests_programmes

Rake::TestTask.new(:tests_programmes) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList['spec/**/*_spec.rb'] - FileList['spec/**/svar*_spec.rb']
end

Rake::TestTask.new(:tous_les_tests) do |t|
  # Utile pour les cibles auxiliaires/individuelles.
  # Donc, doit etre defini
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
end

##################################################
# Remise du code.
##################################################

BOITE='INF5171'

desc "Remise du travail avec oto"
task :remise do
  pwd = ENV['PWD']
  sh %{ssh oto.labunix.uqam.ca oto rendre_tp tremblay_gu #{BOITE} #{CODES_PERMANENTS}\
     #{pwd}/lib/svar/svar.rb\
     #{pwd}/bin/wavefront.rb\
     #{pwd}/bin/graphe.rb\
     #{pwd}/bin/services.rb}
  sh %{ssh oto.labunix.uqam.ca oto confirmer_remise tremblay_gu #{BOITE} #{CODES_PERMANENTS}}
end

