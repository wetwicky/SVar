default: svar_new

#DEBUG=--verbose

##################################
# Tests unitaires
##################################
svar_new:
	ruby -Ilib -Ispec spec/svar_new_spec.rb $(DEBUG)

svar_value:
	ruby -Ilib -Ispec spec/svar_value_spec.rb $(DEBUG)

svar_state:
	ruby -Ilib -Ispec spec/svar_state_spec.rb $(DEBUG)

svar_writable:
	ruby -Ilib -Ispec spec/svar_writable_spec.rb $(DEBUG)

svar_mutable:
	ruby -Ilib -Ispec spec/svar_mutable_spec.rb $(DEBUG)

svar_frozen:
	ruby -Ilib -Ispec spec/svar_frozen_spec.rb $(DEBUG)

svar_eval:
	ruby -Ilib -Ispec spec/svar_eval_spec.rb $(DEBUG)

svar_then:
	ruby -Ilib -Ispec spec/svar_then_spec.rb $(DEBUG)

svar_all_any:
	ruby -Ilib -Ispec spec/svar_all_any_spec.rb $(DEBUG)

tests_unitaires tests: svar_new svar_value svar_state svar_writable svar_mutable svar_frozen svar_eval svar_then svar_all_any

##################################
# Tests programmes.
##################################
fibo:
	ruby -Ilib -Ispec spec/fibo_spec.rb $(DEBUG)

wavefront:
	ruby -Ilib -Ispec spec/wavefront_spec.rb $(DEBUG)

lazy_list:
	ruby -Ilib -Ispec spec/lazy_list_spec.rb $(DEBUG)

graphe:
	ruby -Ilib -Ispec spec/graphe_spec.rb $(DEBUG)

services:
	ruby -Ilib -Ispec spec/services_spec.rb $(DEBUG)

tests_programmes programmes: fibo wavefront lazy_list graphe services


##################################
# Autres
##################################
tous_les_tests: tests programmes
