require 'colorize'

class Polynomial
    def initialize(equation)
      @equation     = equation
      @hash_left    = {}
      @hash_right   = {}
      @solutions    = []
      @degree       = 0
      @delta        = 0
      @max          = 0
    end

    # Calcul de la racine carré de façon tres posé
    def sqrt(x)
      x**(0.5)
    end

    # Trouvé l'exposant de X maximum pour la creation du hash avant reduction
    # ex: 2 * X^0 + 3 * X^1 = 1 * X^0 + 3 * X^14 => @max = 15
    # Oui un tableau commence par 0 d'ou le + 1
    def get_max
      tmp = @equation.split("X^")[1..-1]
      tmp.each do |t|
        value = t.gsub(/\s.+/, '').to_i
        @max = value + 1 unless @max > value
      end
    end

    # Parsing de la string, on met tout dans un hash pour reduire et effectuer
    # des calcul dessus
    def parse
      # Séparation de l'equation
      splitted_equation = @equation.split(" =")

      # Le coté le plus long a gauche
      if splitted_equation.first.length > splitted_equation.last.length
        left = splitted_equation.first
        right = splitted_equation.last
      else
        left = splitted_equation.last
        right = splitted_equation.first
      end

      # On split en tableau chaque termes grace au signe +
      left = left.split('')
      left.each_with_index do |letter, i|
        if left[i] == "-" and left[i + 1] == " "
          left[i] = "+"
          left[i + 1] = "-"
        end
      end
      left = left.join('').split(' +')

      right = right.split('')
      right.each_with_index do |letter, i|
        if right[i] == "-" and right[i + 1] == " "
          right[i] = "+"
          right[i + 1] = "-"
        end
      end
      right = right.join('').split(' +')

      # Creation des hash grace a @max
      left.each do |term|
        value = term.split(" ").first.to_f
        @max.times do |i|
          if term.include? "X^#{i}"
            @hash_left["X^#{i}"] = value unless value == 0.0
          end
        end
      end

      right.each do |term|
        value = term.split(" ").first.to_f
        @max.times do |i|
          if term.include? "X^#{i}"
            @hash_right["X^#{i}"] = value unless value == 0.0
          end
        end
      end

      # On rajoute la petite constante = 0 a gauche si elle a disparu pendant la reduction
      unless @hash_left["X^0"]
        @hash_left["X^0"] = 0.0
      end

      # Inversion des hash si necessaire, on veut le '= 0' a droite
      if @hash_left.count < @hash_right.count
        tmp = @hash_left
        @hash_left = @hash_right
        @hash_right = tmp
      end

    end

    # Reduction de l'equation (on passe tout ce qui est a droite a gauche)
    def reduce
      @max.times do |i|
        if @hash_right["X^#{i}"] and @hash_left["X^#{i}"]
          @hash_left["X^#{i}"] = (@hash_left["X^#{i}"] - @hash_right["X^#{i}"]).floor(1)
          @hash_right.delete("X^#{i}")

          # On detruit la clé si la valeur est egale à 0 biensur
          if @hash_left["X^#{i}"] == 0.0
            @hash_left.delete("X^#{i}")
          end
        end
      end


      # Affichage de la forme reduite, c'est moche mais ça fonctionne
      unless @hash_left.empty? and @hash_right.empty?
        puts "Forme reduite".yellow
        # Cote gauche
        @hash_left.each_with_index do |(key, value), index|
          print "#{value} * #{key} "
          print "+ " unless @hash_left.count == (index + 1)
        end
        print "= "
        # Cote droit si existant
        unless @hash_right.empty?
          @hash_right.each do |key, value|
            print "#{value} * #{key} \n"
          end
        else
          print "0 \n"
        end
      else
        puts "#{@equation}"
      end

    end

    # Determiner le degrée de l'equation, facile on trouve le plus gros exposant
    # restant apres reduction toujours grace a @max
    def degree
      @max.times do |i|
        if @hash_left["X^#{i}"]
          @degree = i
        end
      end

      puts "Polynome du #{@degree}ème degré".yellow unless @degree == 0
    end

    # Resolution de l'equation
    def resolve
      # On execute toute les fonction d'avant
      get_max
      parse
      reduce
      degree

      # Si il y a une quelconque erreur c'est que l'equation est fucked up a l'entrée
      # On la catch histoire de ne pas crash
      begin

        # Si on a un truc du style '1=1'
        if @hash_left.empty? and @degree < 3
          puts "Tous les nombres réels sont solution".green
          return
        end

        # Si le degrée est egale a 0
        if @degree == 0
          puts "Il n'y a pas de solutions".red
        # Degré 1
        elsif @degree == 1
          puts "Il y a une solution".green
          if @hash_left["X^0"]
            @solutions.push((-@hash_left["X^0"] / @hash_left["X^1"]))
          else
            @solutions.push((1 / @hash_left["X^1"]))
          end
        # Degré 2
        elsif @degree == 2
            # Calcul du discriminant (b^4 - 4ac) tmtc les cours de math de seconde
            @delta = (@hash_left["X^1"] ** 2) - 4 * @hash_left["X^2"] * @hash_left["X^0"]
            puts "Delta: #{@delta}".yellow
            # Solutions en fonction du discriminant
            # Delta < 0
            if @delta < 0
              puts "Le polynome n'admet aucune solution réelle".red
              puts "En revanche il admet 2 solutions complexes".green

              @solutions.push("(#{-@hash_left["X^1"]} - i * sqrt(#{@delta.abs})) / 2 * (#{@hash_left["X^2"]})")
              @solutions.push("(#{-@hash_left["X^1"]} + i * sqrt(#{@delta.abs})) / 2 * (#{@hash_left["X^2"]})")

              @solutions.push("Solutions:".green)

              @solutions.push(((-@hash_left["X^1"] - sqrt(@delta)) / (2 * @hash_left["X^2"])).to_c)
              @solutions.push(((-@hash_left["X^1"] + sqrt(@delta)) / (2 * @hash_left["X^2"])).to_c)
            # Delta = 0
            elsif @delta == 0
              puts "Le polynome admet 1 solution réelle".green
              @solutions.push((-@hash_left["X^1"]) / 2 * @hash_left["X^2"])
            # Delta > 0
            else
              puts "Le polynome admet 2 solutions réelles".green
              @solutions.push((-@hash_left["X^1"] - sqrt(@delta)) / (2 * @hash_left["X^2"]))
              @solutions.push((-@hash_left["X^1"] + sqrt(@delta)) / (2 * @hash_left["X^2"]))
            end
        else
          puts "L'equation polynomial est de degré supérieur à 2".red
        end

      rescue Exception
        system "clear"
        puts "Incorrect equation"
      end

      @solutions.each do |solution|
        puts "#{solution}"
      end

    end

end

tests = [
  "1 * X^0 + 2 * X^1 = - 1 * X^0 + 4 * X^1",
  "-1 * X^0 - 2 * X^1 = 1 * X^0 + 2 * X^1",
  "1 * X^0 + 2 * X^1 + 3 * X^2 = - 1 * X^0 + 4 * X^1 + 3 * X^2",
  "1 * X^0 + 2 * X^1 + 2 * X^2 = - 1 * X^0 + 4 * X^1 + 3 * X^2",
  "1 * X^0 + 2 * X^1 + 4 * X^2 = - 1 * X^0 + 4 * X^1 + 3 * X^2",
  "2 * X^0 + 2 * X^1 + 4 * X^2 = - 1 * X^0 + 4 * X^1 + 3 * X^2",
  "1 * X^0 + 2 * X^1 + 4 * X^2 = 0 * X^0 + 4 * X^1 + 3 * X^2",
  "1 * X^0 + 2 * X^1 + 4 * X^2 = 0 * X^0 + 4 * X^1 + 3 * X^2 + 0 * X^3 + 0 * X^4 + 0 * X^5",
  "1 * X^0 + 2.5 * X^1 = - 1.561151 * X^0 + 4.000 * X^1",
  "1.8526 * X^0 + 2.989 * X^1 + 2.16 * X^2 = - 1.122241 * X^0 + 4.999 * X^1 + 3.25 * X^2",
  "1 * X^0 = 2 * X^0",
  "1 * X^0 = 1 * X^0",
  "1 * X^0 + 2 * X^1 + 4 * X^2 = 0 * X^0 + 4 * X^1 + 3 * X^2 + 0 * X^3 + 0 * X^4 + 2 * X^5",
]

# Si on a pas de parametres
if ARGV.length < 1
  puts "Please provide at least an equation"
  return
# Si le parametre est test
elsif ARGV[0] == "tests"
  tests.each do |test|
    polynome = Polynomial.new(test)
    polynome.resolve
  end
# Sinon
else
  polynome = Polynomial.new(ARGV[0])
  polynome.resolve
end
