module RedPOS
	class Tagger
		attr_accessor :classes, :model
	
		def initialize(opts = {})
			if opts[:new_model] == true
			  @classes = opts[:classes]
			  @model = Perceptron.new(@classes)
			else
				# TODO: load an existing model here.
			end
		end
	
		def tag(sentences)
			tags = Array.new

			sentences.each_with_index do |sent, sent_i|
				tags[sent_i] ||= []
				context = [:START, :START2] + sent + [:END, :END2]
				last_tag, secondlast_tag = :START2, :START
				sent.each_with_index do |word, word_i|
					features = get_features(word_i+2, context, last_tag, secondlast_tag)

					prediction = @model.predict(features)
					tags[sent_i] << prediction
					secondlast_tag = last_tag
					last_tag = prediction
				end
			end
			
			return tags
		end
	
		def train(iterations, sentences, tags)
			iterations.times do |iter|
				sentences.each_with_index do |sent, sent_i|
					context = [:START, :START2] + sent + [:END, :END2]
					last_tag, secondlast_tag = :START2, :START
					sent.each_with_index do |word, word_i|
						features = get_features(word_i+2, context, last_tag, secondlast_tag)

						prediction = @model.predict(features)
						true_tag = tags[sent_i][word_i]
	
						@model.update(prediction, features, true_tag)

						secondlast_tag = last_tag
						last_tag = prediction
					end
				end
			end
			@model.average
		end
	
		def get_features(i, sentence, last_tag, secondlast_tag)
			features = Hash.new(0)
	
			features["Wi: #{sentence[i]}"] = 1
			features["Wi-1: #{sentence[i-1]}"] = 1
			features["Wi-2: #{sentence[i-2]}"] = 1
			features["Wi+1: #{sentence[i+1]}"] = 1
			features["Wi+2: #{sentence[i+2]}"] = 1
			features["Ti-1: #{last_tag}"] = 1
			features["Ti-2: #{secondlast_tag}"] = 1
			features["Ti-1, Ti-2: #{last_tag}, #{secondlast_tag}"] = 1
			features["Wi-1 suffix: #{sentence[i][0, 3]}"] = 1
			features["Wi-1 prefix: #{sentence[i][-3, 3]}"] = 1
			features["Contains hyphen"] = 1 if sentence[i]["-"]
			features["Contains number"] = 1 if sentence[i][/\d/]
			return features
		end
	
	end
end
