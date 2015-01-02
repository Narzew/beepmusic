require 'zlib'

=begin
File.open(ARGV[0],'rb'){|f|
	sounds = []
	s = f.read
	bites = s.split(";")
	bites.each{|y|
		z = y.split(",")
		if z[3].to_i == nil
			z[3].to_i = 1
		end
		z[0] = z[0].to_i
		z[1] = z[1].to_i
		z[2] = z[2].to_i
		z[3] = z[3].to_i
		system("beep -f #{z[0]} -l #{z[1]} -d #{z[2]} -r #{z[3]}")
		sounds << [z[0],z[1],z[2],z[3]]
	}
}
20000.times{|x|
	system("beep -f #{x} -l #{15} -d 1 -r 1")
	puts x
}
=end
=begin
FORMAT

BPM string
music_name name
music_author author
music_description desc
frequencies
freq1 mode (freq,upto,down) base1 base2 length delay repeats
freq2 freq 100 30 10 6
#Comment
freq3 up 100 500 30 10 3 


BPM
name Test
author Narzew
desc This is test music
enname Test
endesc This is test music
# Testowa 1
test1 freq 300 50 10 3
# Testowa zwiększająca
test2 change 50 200 10 3 3
# Testowa zmniejszająca
test3 change 200 50 15 7 2
endfreq

test1^10
test2^20
test3^40
test1^3
test1^test2^3
test1^test2^test3^7
=end

module BPM
	def self.compile_bpm(x,y)
		$frequencies = {}
		$bpm_data = []
		$sounds = []
		data = lambda{File.open(x,'rb'){|f| return f.read}}.call
		if data[0] != "B" && data[1] != "P" && data[2] != "M"
			raise("Invalid BPM file!")
		end
		data.each_line{|l|
			next if l.gsub("\x20","") == "BPM"
			next if l.gsub("\x20","")[0] == "#"
			next if l.gsub("\x20","") == ""
			ldata = l.split(" ")				
			case ldata[0]
			when "name" then $bpm_data[0] = lambda{l[0..4] = ""; return l.gsub("\n","").gsub("\r","") }.call
			when "author" then $bpm_data[1] = lambda{l[0..6] = ""; return l.gsub("\n","").gsub("\r","") }.call
			when "desc" then $bpm_data[2] = lambda{l[0..4] = ""; return l.gsub("\n","").gsub("\r","") }.call
			when "enname" then $bpm_data[3] = lambda{l[0..6] = ""; return l.gsub("\n","").gsub("\r","") }.call
			when "endesc" then $bpm_data[4] = lambda{l[0..6] = ""; return l.gsub("\n","").gsub("\r","") }.call
			end
			case ldata[1]
			when "freq"
				$frequencies[ldata[0]] = [0,ldata[2].to_i,ldata[3].to_i,ldata[4].to_i,ldata[5].to_i]
			when "change"
				if ldata[2] < ldata[3]
					$frequencies[ldata[0]] = [1,ldata[2].to_i,ldata[3].to_i,ldata[4].to_i,ldata[5].to_i,ldata[6].to_i]
				else
					$frequencies[ldata[0]] = [2,ldata[2].to_i,ldata[3].to_i,ldata[4].to_i,ldata[5].to_i,ldata[6].to_i]
				end
			end
			lfdata = l.split("^")
			if lfdata.size == 2
				lfdata[1].to_i.times{
					if $frequencies[lfdata[0]][0] == 0
						$sounds << [$frequencies[lfdata[0]][1],$frequencies[lfdata[0]][2],$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4]]
					elsif $frequencies[lfdata[0]][0] == 1
						cl = $frequencies[lfdata[0]][1]
						dl = $frequencies[lfdata[0]][2]
						while cl <= dl
							$sounds << [cl,$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4],$frequencies[lfdata[0]][5]]
							cl += 1
						end
					elsif $frequencies[lfdata[0]][0] == 2
						cl = $frequencies[lfdata[0]][1]
						dl = $frequencies[lfdata[0]][2]
						while cl >= dl
							$sounds << [cl,$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4],$frequencies[lfdata[0]][5]]
							cl -= 1
						end
					end
				}
			elsif lfdata.size == 3
				lfdata[2].to_i.times{
					if $frequencies[lfdata[0]][0] == 0
						$sounds << [$frequencies[lfdata[0]][1],$frequencies[lfdata[0]][2],$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4]]
					elsif $frequencies[lfdata[0]][0] == 1
						cl = $frequencies[lfdata[0]][1]
						dl = $frequencies[lfdata[0]][2]
						while cl <= dl
							$sounds << [cl,$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4],$frequencies[lfdata[0]][5]]
							cl += 1
						end
					elsif $frequencies[lfdata[0]][0] == 2
						cl = $frequencies[lfdata[0]][1]
						dl = $frequencies[lfdata[0]][2]
						while cl >= dl
							$sounds << [cl,$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4],$frequencies[lfdata[0]][5]]
							cl -= 1
						end
					end
					if $frequencies[lfdata[1]][0] == 0
						$sounds << [$frequencies[lfdata[1]][1],$frequencies[lfdata[1]][2],$frequencies[lfdata[1]][3],$frequencies[lfdata[1]][4]]
					elsif $frequencies[lfdata[1]][0] == 1
						cl = $frequencies[lfdata[1]][1]
						dl = $frequencies[lfdata[1]][2]
						while cl <= dl
							$sounds << [cl,$frequencies[lfdata[1]][3],$frequencies[lfdata[1]][4],$frequencies[lfdata[1]][5]]
							cl += 1
						end
					elsif $frequencies[lfdata[1]][0] == 2
						cl = $frequencies[lfdata[1]][1]
						dl = $frequencies[lfdata[1]][2]
						while cl >= dl
							$sounds << [cl,$frequencies[lfdata[1]][3],$frequencies[lfdata[1]][4],$frequencies[lfdata[1]][5]]
							cl -= 1
						end
					end
				}
			elsif lfdata.size == 4
				lfdata[3].to_i.times{
					if $frequencies[lfdata[0]][0] == 0
						$sounds << [$frequencies[lfdata[0]][1],$frequencies[lfdata[0]][2],$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4]]
					elsif $frequencies[lfdata[0]][0] == 1
						cl = $frequencies[lfdata[0]][1]
						dl = $frequencies[lfdata[0]][2]
						while cl <= dl
							$sounds << [cl,$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4],$frequencies[lfdata[0]][5]]
							cl += 1
						end
					elsif $frequencies[lfdata[0]][0] == 2
						cl = $frequencies[lfdata[0]][1]
						dl = $frequencies[lfdata[0]][2]
						while cl >= dl
							$sounds << [cl,$frequencies[lfdata[0]][3],$frequencies[lfdata[0]][4],$frequencies[lfdata[0]][5]]
							cl -= 1
						end
					end
					if $frequencies[lfdata[1]][0] == 0
						$sounds << [$frequencies[lfdata[1]][1],$frequencies[lfdata[1]][2],$frequencies[lfdata[1]][3],$frequencies[lfdata[1]][4]]
					elsif $frequencies[lfdata[1]][0] == 1
						cl = $frequencies[lfdata[1]][1]
						dl = $frequencies[lfdata[1]][2]
						while cl <= dl
							$sounds << [cl,$frequencies[lfdata[1]][3],$frequencies[lfdata[1]][4],$frequencies[lfdata[1]][5]]
							cl += 1
						end
					elsif $frequencies[lfdata[1]][0] == 2
						cl = $frequencies[lfdata[1]][1]
						dl = $frequencies[lfdata[1]][2]
						while cl >= dl
							$sounds << [cl,$frequencies[lfdata[1]][3],$frequencies[lfdata[1]][4],$frequencies[lfdata[1]][5]]
							cl -= 1
						end
					end
					if $frequencies[lfdata[2]][0] == 0
						$sounds << [$frequencies[lfdata[2]][1],$frequencies[lfdata[2]][2],$frequencies[lfdata[2]][3],$frequencies[lfdata[2]][4]]
					elsif $frequencies[lfdata[2]][0] == 1
						cl = $frequencies[lfdata[2]][1]
						dl = $frequencies[lfdata[2]][2]
						while cl <= dl
							$sounds << [cl,$frequencies[lfdata[2]][3],$frequencies[lfdata[2]][4],$frequencies[lfdata[2]][5]]
							cl += 1
						end
					elsif $frequencies[lfdata[2]][0] == 2
						cl = $frequencies[lfdata[2]][1]
						dl = $frequencies[lfdata[2]][2]
						while cl >= dl
							$sounds << [cl,$frequencies[lfdata[2]][3],$frequencies[lfdata[2]][4],$frequencies[lfdata[2]][5]]
							cl -= 1
						end
					end
				}
			end
		}
		$bpm_data[5] = $sounds
		$result = ["CBM1",$bpm_data]
		File.open(y,'wb'){|w|w.write(Zlib::Deflate.deflate(Marshal.dump($result),9))}
	end
	def self.play_bpm(x)
		data = lambda{File.open(x,'rb'){|f| return Marshal.load(Zlib::Inflate.inflate(f.read))}}.call
		if data[0] != "CBM1"
			print "Invalid CBM file!"
			exit
		else
			data = data[1]
		end
		size1 = data[5].size
		print "Name: #{data[0]}\nAuthor: #{data[1]}\nDescription: #{data[2]}\nEnglish name: #{data[3]}\nEnglish description: #{data[4]}\nLength: #{size1} beeps\n"
		print "Press ENTER to play.\n"
		$stdin.gets
		count = 1
		data[5].each{|y|
			system("beep -f #{y[0]} -l #{y[1]} -d #{y[2]} -r #{y[3]}")
			print "Beep #{count}/#{size1}\nActual beep: Freq: #{y[0]} Length: #{y[1]} Delay #{y[2]} Repeats #{y[3]}\n"
			count += 1
		}
	end
end

begin
	print "BeepMusic v 1.00 by Narzew\nBPM and CBM formats (C) Narzew\nv 1.00\nAll rights reserved\n"
	case ARGV[0]
	when "compile"
		BPM.compile_bpm(ARGV[1],ARGV[2])
	when "play"
		BPM.play_bpm(ARGV[1])
	else
		print "Usage:\nBeepMusic.rb compile input output - to compile\nBeepMusic.rb play input - to play\n"
	end
end
