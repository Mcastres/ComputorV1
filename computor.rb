class Polynomial
    def initialize(equation)
      @equation     = equation
      @hash_left    = {}
      @hash_right   = {}
      @solutions    = []
      @degree       = 0
      @delta        = 0
    end

    # Réduit l'equation
    def parse
      # Séparation de l'equation
      splitted_equation = @equation.split(" = ")

      # Deux cotés de celle-ci
      left  = splitted_equation.first
      right = splitted_equation.last

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
        if term.include? "X^0"
          @hash_left["X^0"] = value == 0.0 ? 1.0 : value
        elsif term.include? "X^1"
          @hash_left["X^1"] = value == 0.0 ? 1.0 : value
        elsif term.include? "X^2"
          @hash_left["X^2"] = value == 0.0 ? 1.0 : value
        elsif term.include? "X^3"
          @hash_left["X^3"] = value == 0.0 ? 1.0 : value
        end
      end

      # Right hash
      right.each do |term|
        value = term.split(" ").first.to_f
        if term.include? "X^0"
          @hash_right["X^0"] = value == 0.0 ? 1.0 : value
        elsif term.include? "X^1"
          @hash_right["X^1"] = value == 0.0 ? 1.0 : value
        elsif term.include? "X^2"
          @hash_right["X^2"] = value == 0.0 ? 1.0 : value
        elsif term.include? "X^3"
          @hash_right["X^3"] = value == 0.0 ? 1.0 : value
        end
      end

    end

    # Reduction de l'equation
    def reduce
      if @hash_right["X^0"]
        @hash_left["X^0"] = (@hash_left["X^0"] - @hash_right["X^0"]).floor(1)
      elsif @hash_right["X^1"]
        @hash_left["X^1"] = (@hash_left["X^1"] - @hash_right["X^1"]).floor(1)
      elsif @hash_right["X^2"]
        @hash_left["X^2"] = (@hash_left["X^2"] - @hash_right["X^2"]).floor(1)
      elsif @hash_right["X^3"]
        @hash_left["X^3"] = (@hash_left["X^3"] - @hash_right["X^3"]).floor(1)
      end

      # Affichage de l'equation reduite
      puts @hash_left
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

      puts "Plynome du #{@degree}ème degré"
    end

    # Resolution de l'equation
    def resolve
      self.parse
      self.reduce
      self.degree

      # Si c'est du second degré...
      if @degree == 2
          # Calcul du discriminant
          @delta = (@hash_left["X^1"] ** 2) - 4 * @hash_left["X^2"] * @hash_left["X^0"]
          puts "Delta: #{@delta}"
          # Solutions
          if @delta < 0
            puts "Le polynome ne possede aucune solution réelle"
          elsif @delta == 0
            puts "Le polynome possede 1 solution réelle"
            @solutions.push((-@hash_left["X^1"]) / 2 * @hash_left["X^2"])
          else
            puts "Le polynome possede 2 solutions réelles"
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
