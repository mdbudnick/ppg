require 'io/console'

class PPGThread
    def initialize(switch_time, user_1, user_2, threads, pairing_manager)
        @switch_time = switch_time
        @user_1 = user_1
        @user_2 = user_2
        @threads = threads
        @pairing_manager = pairing_manager
        @strings = [""]
    end

    def run
        @threads << Thread.new do
            @threads << Thread.new do
                string = ""
                loop do
                    handle_key_press
                    if @strings[-1].length > 0
                        puts @strings[-1]
                    end


                   if @pairing_manager.needs_nav_change
                       puts "It has been #{@switch_time/60} minutes.  Please change the navigator"
                    end
#                   process(input)
                end
            end
            @threads << Thread.new do
                loop do
                    if !@pairing_manager.needs_nav_change
                        sleep @switch_time
                        @pairing_manager.needs_nav_change = true
                        @pairing_manager.prompt_nav_change
                    end
                end
            end
            @threads.each {|thread| thread.abort_on_exception = true}
        end
        @threads.each {|thread| thread.abort_on_exception = true}
    end

    def read_char
      STDIN.echo = false
      STDIN.raw!

      input = STDIN.getc.chr
      if input == "\e" then
        input << STDIN.read_nonblock(3) rescue nil
        input << STDIN.read_nonblock(2) rescue nil
      end
    ensure
      STDIN.echo = true
      STDIN.cooked!

      return input
    end

    def handle_key_press
      c = read_char
      case c
      when " "
        puts "SPACE"
      when "\t"
        puts "TAB"
      when "\r"
        if @strings[-1].length > 0
            @strings << ""
        else
            puts ""
        end
        if @strings.length > 100
            @strings = @strings.drop(@strings.length - 100)
        end
      when "\n"
        puts "LINE FEED"
      when "\e"
        puts "ESCAPE"
      when "\e[A"
        puts "UP ARROW"
      when "\e[B"
        puts "DOWN ARROW"
      when "\e[C"
        puts "RIGHT ARROW"
      when "\e[D"
        puts "LEFT ARROW"
      when "\177"
        puts "BACKSPACE"
      when "\004"
        puts "DELETE"
      when "\e[3~"
        puts "ALTERNATE DELETE"
      when "\u0003"
        puts "CONTROL-C"
        exit 0
      when /^.$/
        @strings[-1] << c
      else
        puts "SOMETHING ELSE: #{c.inspect}"
      end
    end
        


    def process(input)
        puts "General input #{input}"
    end
end
