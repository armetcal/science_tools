// Assign default button values

function do_onclick() {

    // Number of codons
    var n_codons = [0,1,2,2,3,3,4,4];
    var random1 = Math.floor(Math.random() * n_codons.length);
    var num_codons = n_codons[random1];
    var description1 = 'A bacterial gene was sequenced and a small stretch of this double-stranded DNA is shown below. Only the <b>start codon (AUG), '
    var description2 = ' amino acid(s), and the stop codon (UAA, UAG, or UGA)</b> of the protein are represented by this DNA sequence (i.e. the DNA downstream of the promoter, after the +1 site and before the terminator).'
    document.getElementById("num_codons").innerHTML = description1 + num_codons.toString() + description2;

    // Variables
    var button1_value = 0;
    var button2_value = 0;
    var button3_value = 0;
    var button4_value = 0;
    var last_answer = 0;
    var last_hint = 0;
    const total_length = 35;

    // Codon Table
    const ct = {'Ala': ['GCA','GCC','GCG','GCT'], 
                    'Arg': ['AGA','AGG','CGA','CGC','CGG','CGT'], 
                    'Asn': ['AAC','AAT','GAC','GAT'],
                    'Cys': ['TGC','TGT'],
                    'Gln': ['CAA','CAG'],
                    'Glu': ['GAA','GAG'],
                    'Gly': ['GGA','GGC','GGG','GGT'],
                    'His': ['CAC','CAT'],
                    'Ile': ['ATA','ATC','ATT'],
                    'Leu': ['CTA','CTC','CTG','CTT','TTA','TTG'],
                    'Lys': ['AAA','AAG'],
                    'Met': ['ATG'],
                    'Phe': ['TTC','TTT'],
                    'Pro': ['CCA','CCC','CCG','CCT'],
                    'Ser': ['AGC','AGT','TCA','TCC','TCG','TCT'],
                    'Stp': ['TAA','TAG','TGA'],
                    'Thr': ['ACA','ACC','ACG','ACT'],
                    'Trp': ['TGG'],
                    'Tyr': ['TAC','TAT'],
                    'Val': ['GTA','GTC','GTG','GTT']
                    };
                    
    var ct_stop = $.extend( true, {}, ct);
    var ct_stop = ct_stop.Stp;
    var ct_nostop = $.extend( true, {}, ct);
    delete ct_nostop.Stp;
    //console.log(ct);
    //console.log(ct_stop);
    //console.log(ct_nostop);
    // Assign top/bottom strand
    var temp = ['top','bottom'];
    var random2 = Math.round(Math.random());
    var direction = temp[random2];
    // Determine protein code
    var protein = [];
    var bases = ['A','T','G','C'];
    while(protein.length<num_codons){
        let b1 = bases[Math.floor(Math.random() * 4)];
        let b2 = bases[Math.floor(Math.random() * 4)];
        let b3 = bases[Math.floor(Math.random() * 4)];
        let cdn = b1+b2+b3;
        if(!(ct_stop.includes(cdn))){
            protein.push(cdn);  
        } 
    }  
    
    // Assemble coding strand
    var final_string = 'ATG' + protein.join('') + ct_stop[Math.floor(Math.random() * 3)];
    var num_bases_needed = 35-final_string.length;
    var extra_bases_1 = Math.floor(Math.random() * (1+num_bases_needed));
    var extra_bases_2 = num_bases_needed - extra_bases_1;
    var pre = [];
    while(pre.length<extra_bases_1){
        pre.push(bases[Math.floor(Math.random() * 4)]);
    }
    var post = [];
    while(post.length<extra_bases_2){
        post.push(bases[Math.floor(Math.random() * 4)]);
    }
    var complete_string = pre.join('') + final_string + post.join('');
    console.log(final_string);
    console.log(complete_string);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Add wrong start codons
    // All unchangeable bases: start/stop codon, any bases that would run into start/stop
    var e = extra_bases_1;
    var e2 = total_length-extra_bases_2;
    var untouchable = [e-2,e-1,e,e+1,e+2,e2-5,e2-4,e2-3,e2-2,e2-1];
    // Determine # of fake start codons
    var fake_atg = Math.round(Math.random());
    var fake_cat = Math.round(Math.random()+1);
    // Add fake atg
    var changeable = Array.from({length: (total_length-3)}, (_, index) => index + 1);
    console.log(changeable);
    var changeable = changeable.filter(b => !(untouchable.includes(b)));
    if(fake_atg == 1){
        var temp = changeable[Math.floor(Math.random() * changeable.length)];
        var remove_from_changeable_for_gta = [temp,temp+1,temp+2];
        var changeable = changeable.filter(b => !(remove_from_changeable_for_gta.includes(b)));
        var complete_string = complete_string.split('')
        complete_string[temp] = 'A';
        complete_string[temp+1] = 'T';
        complete_string[temp+2] = 'G';
        var complete_string = complete_string.join('');
    }
    // Add fake cat
    while(fake_cat>0){
        var temp = changeable[Math.floor(Math.random() * changeable.length)];
        var remove_from_changeable_for_gta = [temp,temp+1,temp+2];
        var changeable = changeable.filter(b => !(remove_from_changeable_for_gta.includes(b)));
        var complete_string = complete_string.split('')
        complete_string[temp] = 'C';
        complete_string[temp+1] = 'A';
        complete_string[temp+2] = 'T';
        var complete_string = complete_string.join('');
        var fake_cat = fake_cat-1;
    }
    // Check for multiple correct answers
    var num_atg = [];
    var indexOccurence = complete_string.indexOf('ATG', 0);
    while(indexOccurence >= 0) {
        num_atg.push(indexOccurence);
        indexOccurence = complete_string.indexOf('ATG', indexOccurence + 1);
    }
    var num_atg = num_atg.filter(b => b != extra_bases_1);
    for(var i = 0; i<num_atg.length; i++){
        var temp = i+3+(3*num_codons);
        var temp2 = complete_string.substring(temp,temp+2);
        if(ct_stop.includes(temp2)){
            if(changeable.includes(temp)){
                var complete_string = complete_string.split('')
                complete_string[temp] = 'C'
                var complete_string = complete_string.join('');
                var changeable = changeable.filter(b => b != temp);
            } else if(changeable.includes(temp+1)){
                var complete_string = complete_string.split('')
                complete_string[temp+1] = 'C'
                var complete_string = complete_string.join('');
                var changeable = changeable.filter(b => b != temp+1);
            } else if(changeable.includes(temp+2)){
                var complete_string = complete_string.split('')
                complete_string[temp+2] = 'C'
                var complete_string = complete_string.join('');
                var changeable = changeable.filter(b => b != temp+2);
            } else {
                var e = new Error('Error - please generate new problem');
                throw e;
            }

        }
    }
    var num_cat = [];
    var indexOccurence = complete_string.indexOf('CAT', 0);
    while(indexOccurence >= 0) {
        num_cat.push(indexOccurence);
        indexOccurence = complete_string.indexOf('CAT', indexOccurence + 1);
    }
    for(var i = 0; i<num_cat.length; i++){
        var temp = i+3+(3*num_codons);
        var temp2 = complete_string.substring(temp,temp+2);
        var temp3 = ['TTA','CTA','TCA']
        if(temp3.includes(temp2)){
            if(changeable.includes(temp)){
                var complete_string = complete_string.split('')
                complete_string[temp] = 'G'
                var complete_string = complete_string.join('');
                var changeable = changeable.filter(b => b != temp);
            } else if(changeable.includes(temp+1)){
                var complete_string = complete_string.split('')
                complete_string[temp+1] = 'G'
                var complete_string = complete_string.join('');
                var changeable = changeable.filter(b => b != temp+1);
            } else if(changeable.includes(temp+2)){
                var complete_string = complete_string.split('')
                complete_string[temp+2] = 'G'
                var complete_string = complete_string.join('');
                var changeable = changeable.filter(b => b != temp+2);
            } else {
                var e = new Error('Error - please generate new problem');
                throw e;
            }

        }
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Reverse if necessary
    if(direction=='bottom'){
        var template_strand = 'Top';
        var complete_string = complete_string.split('');
        var complete_string = complete_string.reverse();
        var complete_string = complete_string.join('');
    } else {
        var template_strand = 'Bottom'
    }
    // Create template strand
    const base_key = { // coding: [template, mRNA]
        'A':['T','A'],
        'T':['A','U'],
        'G':['C','G'],
        'C':['G','C']
    }
    var df = complete_string.split('');
    var coding = complete_string;
    var template = ''
    var mRNA = ''
    for(var i = 0; i<coding.length; i++){
        var temp = coding[i];
        var template = template + base_key[temp][0];
        var mRNA = mRNA + base_key[temp][1];
    }
    console.log(coding);
    console.log(template);
    console.log(mRNA);
        
    // Combine - will have to print one on top of each other
    if(direction=='top'){
        var output_top = '5-' + coding + '-3';
        var output_bottom = '3-' + template + '-5';
    } else {
        var output_top = '5-' + template + '-3';
        var output_bottom = '3-' + coding + '-5';
    }
    document.getElementById("output_top").innerHTML = output_top;
    document.getElementById("output_bottom").innerHTML = output_bottom;
}