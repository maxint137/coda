open Fields
module N = Nat

module Fq =
  Make_fp
    (N)
    (struct
      let order =
        N.of_string
          "41898490967918953402344214791240637128170709919953949071783502921025352812571106773058893763790338921418070971888253786114353726529584385201591605722013126468931404347949840543007986327743462853720628051692141265303114721689601"
    end)

module Pairing_info = struct
  let twist = Fq.(zero, one)

  let loop_count =
    N.of_string
      "204691208819330962009469868104636132783269696790011977400223898462431810102935615891307667367766898917669754470400"

  let is_loop_count_neg = true

  let final_exponent =
    N.of_string
      "73552111470802397192299133782080682301728710523587802164414953272757803714910813694725910843025422137965798141904448425397132210312763036419196981551382130855705368355580393262211100095907456271531280742739919708794230272306800896198050256355512255795343046414500439648235407402928016221629661971660368018858492377211675996627011913832155809286572006511506918479348970121218134056996473102963627909657625079190739882316882751992741238799066378820181352081085141743775089602078041985556107852922590029377522580702957164527112688206145822971278968699082020672631957410786162945929223941353438866102009621402205679750863679130426460044792078113778548067020007452390228240608175718400"

  let final_exponent_last_chunk_abs_of_w0 =
    N.of_string
      "204691208819330962009469868104636132783269696790011977400223898462431810102935615891307667367766898917669754470399"

  let final_exponent_last_chunk_is_w0_neg = true

  let final_exponent_last_chunk_w1 = N.of_string "1"
end