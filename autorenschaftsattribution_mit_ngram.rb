# encoding: UTF-8

#Datei einlesen
def read_data path
	data = File.new(path, "r")
	data = data.read
	if !data.valid_encoding?
		data 			=data.encode("UTF16be", :invalid=>:replace, :replace=>"?").encode('UTF-	8')data.gsub(/[^[:print:]]/i, '')
	end
	return data
end

#Dateien der Aufgabe A einlesen
train_a = read_data ("D:\\HA datasets\\pan12-authorship-attribution-training-corpus-2012-03-28\\12AtrainA.txt")
train_b = read_data ("D:\\HA datasets\\pan12-authorship-attribution-training-corpus-2012-03-28\\12AtrainB.txt")
train_c = read_data ("D:\\HA datasets\\pan12-authorship-attribution-training-corpus-2012-03-28\\12AtrainC.txt")

test1 = read_data("D:\\HA datasets\\pan12-authorship-attribution-test-corpus-2012-05-24\\12Atest01.txt")
test2 = read_data("D:\\HA datasets\\pan12-authorship-attribution-test-corpus-2012-05-24\\12Atest02.txt")
test3 = read_data("D:\\HA datasets\\pan12-authorship-attribution-test-corpus-2012-05-24\\12Atest03.txt")
test4 = read_data("D:\\HA datasets\\pan12-authorship-attribution-test-corpus-2012-05-24\\12Atest04.txt")
test5 = read_data("D:\\HA datasets\\pan12-authorship-attribution-test-corpus-2012-05-24\\12Atest05.txt")
test6 = read_data("D:\\HA datasets\\pan12-authorship-attribution-test-corpus-2012-05-24\\12Atest06.txt")
  
def compare2p data1,data2,n,m
	#character n_gram 
	def char_ngram data,n
		i = 0
		ngrams = Array.new
		while i < data.length-(n-1)  do
			ngram = data[i,n]
			ngrams << ngram
			i += 1
		end
		return ngrams
	end
	ngrams1 = char_ngram(data1,n)
	ngrams2 = char_ngram(data2,n)


	"Autorenprofil erstellen (die N haeufigsten char N-Gramme
	bzw. die Laenge der N-Gramme)"
	def ngrams_sorted ngrams,m
		dic = Hash.new(0)
		for ngram in ngrams
			dic[ngram] +=1
		end
		profil = dic.sort_by { |ngram, value| -value } [0,m]
		#profil.each { |entry| puts "#{entry[0]}: #{entry[1]}\n" }
		return profil
	end
	p1 = ngrams_sorted(ngrams1,m)
	p2 = ngrams_sorted(ngrams2,m)
	#puts p1[0,20]
	#puts p2[0,20]
	
	
	"Aehlichkeit-Vektor erstellen
	z.B.a1 = [['aaa', 100],['bbb',80],['ccc',60],['ddd',50]]
		a2 = [['aaa',105],['ccc',80],['bbb',75],['eed',70]]
	gewueschtes Ergebnis:
	a1 = [['aaa', 100],['bbb',80],['ccc',60],['ddd',50], ['eee,0]]
	a2 = [['aaa',105],,['bbb',75],['ccc',80],['ddd',0],['ee3',70]]"
	
	#Vereinigungsmenge von p1 und p2
	def ngrams_union p1,p2
		i=0
		a1 = Array.new
		while i < p1.length do
			element = p1[i][0]
			a1 << element
			i += 1
		end

		i=0
		a2 = Array.new
		while i < p2.length do
			element = p2[i][0]
			a2 << element
			i += 1
		end
		p_union = a1 | a2
		return p_union
	end
	p_union = ngrams_union(p1,p2)
	
	
	"Anhand der Vereinigungsmenge den Aehnlichleit-Verktor zu erstellen,
	die Elemente, die schon in p sind, werden mit ihren eigenen 
	Wert in einen Hash abgespeichert; die Elemente, die in p nicht
	vorhanden sind, werden mit dem Wert Null ausgefuellt."

	def ngrams_compared p,p_union
		#profile in Hash-Format umwandeln (vorher hat die Klasse Liste)
		p = Hash[*p.flatten]
		
		h1 = Hash.new(0)
		i = 0
		
		
		"um zu testen, ob p den Schluessel in der Liste p_union beinhaltet,
		wenn nicht, wird der Schluessel von p_union mit dem Wert 0 in den 
		neuen Hash (h1) abgespeichert."
	
		while i< p_union.length  
			if p.has_key?(p_union[i]) == false
				h1[p_union[i]] = 0
			end
			i +=1
		end
		
		#Vereinigung von p und h1, sortiert nach Schlüssel
		p_s =Hash[*(p.merge(h1).sort_by {|key,val| key}).flatten]
    
	    return p_s    
	end
	
	
	"die zu vergleichenden Vektoren, die die Element und ihre Anzahl
	des Vorkommens beinhalten. (Klasse: Hash)"
	
	s1 = ngrams_compared(p1,p_union)
	s2 = ngrams_compared(p2,p_union)
	
	#Um die Werte jedes Schlüssels in dem Hash zu bekommen
	vec1 = s1.values
	vec2 = s2.values
    
    #der Dissimilarity-Algorithmus
	def dissim vec1,vec2
		i=0
		up=0
		down=0
		dissimilarity = 0
		while i < vec1.length do
			up  = 2 * ((vec1[i]).to_f - (vec2[i]).to_f)
			down = (vec1[i]).to_f + (vec2[i]).to_f
			dissimilarity += (up/down) ** 2
			i +=1
		end
		
		return dissimilarity
	end
	
	result = dissim vec1, vec2
	return result
end


length_a = train_a.to_s.length
length_b = train_b.to_s.length
#puts length_a, length_b

#Teil: Vorhersagen
def prediction p, t1, t2, t3, t4, t5, t6, n, m, author
	def dissim_score p, t1, t2, t3, t4, t5, t6, n, m
		#Aehnlichkeit zwischen Authorenprofil A und 6 Testdaten
		p_t1 = compare2p p,t1,n,m
		p_t2 = compare2p p,t2,n,m
		p_t3 = compare2p p,t3,n,m
		p_t4 = compare2p p,t4,n,m 
		p_t5 = compare2p p,t5,n,m
		p_t6 = compare2p p,t6,n,m
		
		length_p = p.to_s.length	
		if length_p== 47800 #laenge trainingsdaten A
		"ich kann hier nicht direkt die Variable length_a benutzen,
		sonst wurde Fehlermeldung 'variable nicht definiert' angezeigt"
			profil = "Profil A"
		elsif length_p == 57194 #laenge trainingsdaten B
			profil = "Profil B"
		else 
			profil = "Profil C"
		end	
	
		vec = [p_t1, p_t2, p_t3, p_t4, p_t5, p_t6]
		i = 0
		while i < vec.length  do
			puts "The dissimilarity socre between " + profil + " and " + "test" + 			(i+1).to_s + " is: " + vec[i].to_s
			i+=1
		end
		return vec
	end
    
    vec = dissim_score p, t1, t2, t3, t4, t5, t6, n, m

	#Die 2 kleinsten Dissinilarity Scores und ihre Position zu finden
	def min1_min2 vec,author
		i=0
		min1=vec[0]
		min2=vec[0]
		temp = 0
		while i < vec.length do
			if vec[i] < min1
				temp = min1
				min1 = vec[i]
				min2 = temp
			
			elsif i==0 and vec[i]==min1
				min2 = vec[i+1]
			else
				if vec[i]< min2
					min2 = vec[i]
				end
			end
			i+=1
		end
	
		match1 = vec.index(min1)
		match2 = vec.index(min2)

		i=0
		while i < vec.length do
			if match1 == i 
				puts  author + " is the permutative author of the test text " + 				(i+1).to_s 
			elsif match2 == i
				puts author + " is the permutative author of the test text " + 				(i+1).to_s 
			end
			i+=1
		end
		
		# sortierte Reihefolge
		result = Hash.new
		if match1 < match2
			result[match1 + 1] = author
			result[match2 + 1] = author
		else
			result[match2 + 1] = author
			result[match1 + 1] = author
		end

		return result
	end
	
	author_pred = min1_min2 vec,author
	
	return author_pred
end


"Bei der Anwendung dieses Programms kann man die Parameter die Art von
N-Grammen und die Lae nge der haeufigsten N-Gramme frei angegeben, z.B. Hier
wird 6, d.h. Hexagramm und L=300, d.h. die ersten 300 haeufigsten Hexagramme"
a_t = prediction train_a, test1, test2, test3, test4, test5, test6, 3, 20, "author A"
puts "\n"
b_t = prediction train_b, test1, test2, test3, test4, test5, test6, 3, 20, "author B"
puts "\n"
c_t = prediction train_c, test1, test2, test3, test4, test5, test6, 3, 20, "author C"
puts "\n"

ground_truth = "Gound Truth: \n Author of test text1 is B\n Author of test text2 is A\n Author of test texte is A\n Author of test text4 is C\n Author of test text5 is C\n Author of test text6 is B\n"
puts ground_truth

#Hier beginnt die Evaluation#
results = a_t.keys + b_t.keys + c_t.keys
#puts results

answer = {2 => "author A",
		  3 => "author A",
		  1 => "author B",
		  6 => "author B",
		  4 => "author C",
		  5 => "author C"}

answer = answer.keys

#Evaluation mittels Accuracy
def eval_acc results,answer
	t = 0
	i = 0
	while i < answer.length do
		if results[i] == answer[i]
			t += 1
		end
		i +=1
	end
	accuracy = t.to_f/6.to_f
	
	return accuracy
end

puts eval_acc results,answer
 

