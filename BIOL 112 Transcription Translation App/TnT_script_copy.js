function do_onclick()
            {
                const n_codons = [0,1,2,2,3,3,4,4];
                const random = Math.floor(Math.random() * n_codons.length);
                var num_codons = n_codons[random];
                document.getElementById("num_codons").innerHTML = num_codons;

                var AA = ['Ala','Ala','Ala','Ala','Arg','Arg','Arg','Arg','Arg','Arg','Asn',
                'Asn','Asp','Asp','Cys','Cys','Gln','Gln','Glu','Glu','Gly','Gly','Gly',
                'Gly','His','His','Ile','Ile','Ile','Leu','Leu','Leu','Leu','Leu','Leu',
                'Lys','Lys','Met','Phe','Phe','Pro','Pro','Pro','Pro','Ser','Ser','Ser',
                'Ser','Ser','Ser','Stp','Stp','Stp','Thr','Thr','Thr','Thr','Trp','Tyr',
                'Tyr','Val','Val','Val','Val'];
                var Codon = ['GCA','GCC','GCG','GCT','AGA','AGG','CGA','CGC','CGG','CGT',
                'AAC','AAT','GAC','GAT','TGC','TGT','CAA','CAG','GAA','GAG','GGA','GGC',
                'GGG','GGT','CAC','CAT','ATA','ATC','ATT','CTA','CTC','CTG','CTT','TTA',
                'TTG','AAA','AAG','ATG','TTC','TTT','CCA','CCC','CCG','CCT','AGC','AGT',
                'TCA','TCC','TCG','TCT','TAA','TAG','TGA','ACA','ACC','ACG','ACT','TGG',
                'TAC','TAT','GTA','GTC','GTG','GTT'];
                function getAllIndexes(arr, val) {
                    var indexes = [], i = -1;
                    while ((i = arr.indexOf(val, i+1)) != -1){
                        indexes.push(i);
                    }
                    return indexes;
                }
                var indexes = getAllIndexes(AA, "Stp");

                function no_stops(arr, ind){
                    for (var i = ind.length -1; i >= 0; i--)
                    arr.splice(ind[i],1);
                }
                var ct_nostop = [nostops(AA,indexes),nostops(Codon)

                document.getElementById("test").innerHTML = indexes;
            }  