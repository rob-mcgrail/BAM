module Colourize

colour_codes = {
                :black => 30,   :white => 37,   :red => 31,     :green => 32,
                :yellow => 33,  :blue => 34,    :magenta => 35,  :cyan => 36
}

text_effects = {
                :blink => 5,    :underline => 4,  :bright => 1
}

  # Creating 'string'.red

  colour_codes.each do |colour, colour_code|
    send :define_method, colour do
      ansi = "\e[#{colour_code}m"; reset = "\e[0m"
      colourized_string = ansi + self + reset
      colourized_string
    end

  # Creating 'string'.red_with_underline

    text_effects.each do |effect, effect_code|
      method_name = colour.to_s + '_with_' + effect.to_s
      send :define_method, method_name.to_sym do
        ansi = "\e[#{colour_code};#{effect_code}m"; reset = "\e[0m"
        colourized_string = ansi + self + reset
        colourized_string
      end
    end
  end

  # Creating 'string'.underline

  text_effects.each do |effect, effect_code|
    send :define_method, effect do
      ansi = "\e[#{effect_code}m"; reset = "\e[0m"
      affected_string = ansi + self + reset
      affected_string
    end
  end

  # Creating 'string'.white_on_red

  colour_codes.each do |f_colour, f_colour_code|
    colour_codes.each do |bg_colour, bg_colour_code|
      method_name = f_colour.to_s + '_on_' + bg_colour.to_s
      send :define_method, method_name.to_sym do
        ansi = "\e[#{f_colour_code};#{bg_colour_code+10}m"; reset = "\e[0m"
        colourized_string = ansi + self + reset
        colourized_string
      end

      # Creating 'string'.white_on_red_with_underline

      text_effects.each do |effect, effect_code|
        method_name = f_colour.to_s + '_on_' + bg_colour.to_s + '_with_' + effect.to_s
        send :define_method, method_name.to_sym do
          ansi = "\e[#{f_colour_code};#{bg_colour_code+10};#{effect_code}m"; reset = "\e[0m"
          colourized_string = ansi + self + reset
          colourized_string
        end
      end
    end
  end
end

class String
  include Colourize
end

