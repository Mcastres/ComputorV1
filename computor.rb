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

    def get_max
      @equation.split('').each_with_index do |letter, index|
        if letter == "^"
          @max = @equation[index + 1].to_i if @max.to_i < @equation[index + 1].to_i
        end
      end
      @max += 1
    end

    # Réduit l'equation
    def parse
      # Séparation de l'equation
      splitted_equation = @equation.split(" = ")

      if splitted_equation.first.length > splitted_equation.last.length
        left = splitted_equation.first
        right = splitted_equation.last
      else
        left = splitted_equation.last
        right = splitted_equation.first
      end

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

      # Left hash
      left.each do |term|
        value = term.split(" ").first.to_f
        @max.times do |i|
          if term.include? "X^#{i}"
            @hash_left["X^#{i}"] = value == 0.0 ? 1.0 : value
          end
        end
      end

      # Right hash
      right.each do |term|
        value = term.split(" ").first.to_f
        @max.times do |i|
          if term.include? "X^#{i}"
            @hash_right["X^#{i}"] = value == 0.0 ? 1.0 : value
          end
        end
      end

    end

    # Reduction de l'equation
    def reduce
      @max.times do |i|
        if @hash_right["X^#{i}"]
          if @hash_right["X^#{i}"] > @hash_left["X^#{i}"]
            @hash_right["X^#{i}"] = (@hash_right["X^#{i}"] - @hash_left["X^#{i}"]).floor(1)
            @hash_left.delete("X^#{i}")
          else
            @hash_left["X^#{i}"] = (@hash_left["X^#{i}"] - @hash_right["X^#{i}"]).floor(1)
            @hash_right.delete("X^#{i}")
          end
          if @hash_left["X^#{i}"] == 0.0
            @hash_left.delete("X^#{i}")
          end
        end
      end

      unless @hash_left.empty? and @hash_right.empty?
        puts "Forme reduite".yellow
        # Affichage de l'equation reduite
        @hash_left.each_with_index do |(key, value), index|
          print "#{value} * #{key} "
          print "+ " unless @hash_left.count == (index + 1)
        end
        print "= "
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
      return

    end

    # Determiner le degrée de l'equation
    def degree
      if @hash_left["X^3"]
        puts "L'equation polynomial est de degré supérieur à 2"
        return
      elsif @hash_left["X^2"]
        @degree = 2
      elsif @hash_left["X^1"]
        @degree = 1
      end

      puts "Polynome du #{@degree}ème degré".yellow unless @degree == 0
    end

    # Resolution de l'equation
    def resolve
      self.get_max
      self.parse
      self.reduce
      self.degree

      if @hash_left.empty?
        puts "Tous les nombres réels sont solution".green
        return
      end

      if @degree == 0
        puts "Il n'y a pas de solutions".red
      elsif @degree == 1
        puts "Il y a une solution".green
        @solutions.push((@hash_right["X^0"] / @hash_left["X^1"]))
      elsif @degree == 2
          # Calcul du discriminant
          @delta = (@hash_left["X^1"] ** 2) - 4 * @hash_left["X^2"] * @hash_left["X^0"]
          puts "Delta: #{@delta}".yellow
          # Solutions
          if @delta < 0
            puts "Le polynome ne possede aucune solution réelle".red
          elsif @delta == 0
            puts "Le polynome possede 1 solution réelle".green
            @solutions.push((-@hash_left["X^1"]) / 2 * @hash_left["X^2"])
          else
            puts "Le polynome possede 2 solutions réelles".green
            @solutions.push((-@hash_left["X^1"] - Math.sqrt(@delta)) / (2 * @hash_left["X^2"]))
            @solutions.push((-@hash_left["X^1"] + Math.sqrt(@delta)) / (2 * @hash_left["X^2"]))
          end
      end

      @solutions.each do |solution|
        puts "#{solution}"
      end

    end

end

if ARGV[0].nil? || ARGV[1]
  puts "Please provide just one equation"
  return
end

polynome = Polynomial.new(ARGV[0])
polynome.resolve
