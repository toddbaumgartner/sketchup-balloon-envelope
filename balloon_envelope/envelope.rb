# Sketchup Envelope Drawing Thingee
# <todd.baumgartner@gmail.com> 3/20/2014
# Sorry for how awful this code is, I am still learning the API
# This one will read the output of Deering_Gore_Pattern
# Good Luck


# Change this to the file you would like to build

Paths=[Dir.home + '/Documents','/tmp',Dir.home + '/My Documents']
CSVName = 'Envelope.csv'




# First we pull in the standard API hooks.
require 'csv';
# Create an entry in the Extension list that loads a script called
# envelope.rb
require 'sketchup.rb'


# These are actually used now, 18 standard colors
@color=Hash.new
@color['red'] = 'e8112d'
@color['orange'] = 'f74902'
@color['yellow'] = 'f9e814'
@color['gold'] = 'fcb514'
@color['limegreen'] = '5bbf21'
@color['kellygreen']= '007a3d'
@color['darkgreen'] = '004438'
@color['tealgreen'] = '006d66'
@color['turquoise'] = '005951'
@color['navyblue'] = '002649'
@color['royalblue'] = '0038a8'
@color['ltblue'] = 'b5d1e8'
@color['purple'] = '59118e'
@color['pink'] = 'ed2893'
@color['silver'] = 'dddbd1'
@color['tan'] = 'd3a87c'
@color['white'] = 'ffffff'
@color['black'] = '000000'

# Show the Ruby Console at startup so we can
# see any programming errors we may make.
#SKETCHUP_CONSOLE.show

# Add a menu item to launch our plugin.

UI.menu("Plugins").add_item("Draw Envelope") {
  draw_envelope
}

def draw_panel(sta, width)
		entities = @entities
		z = 0
		@pt2 = @pt1		# Use coordinates from last panel as starting points
		@pt3 = @pt4
		# Station marker is in feet, sketchup wants inches (sta * 12)

		@pt1 = [12 * sta , width * -0.5, z]		 	# Bottom Left
		@pt4 = [12 * sta, width * 0.5, z]		# Top Left

		if (width !=  nil)
			arr = [@pt1, @pt2, @pt3, @pt4].compact.uniq
			if arr.size > 2
	    			new_face = entities.add_face arr
				new_face.pushpull 11
			end
		end
		coordinates = [@pt1] + [0,0,+24]
		point = Geom::Point3d.new @pt1
		text = entities.add_text "Station #{sta.round(2)}", point
end

def draw_panel_disc(radius,sta, height, width, num_gores,panel)
		entities = @entities
		circum = radius * 2 * Math::PI	
		z = 0
		origin = [0,0,200]
		@pt2 = @pt1		# Use coordinates from last panel as starting points
		@pt3 = @pt4
		# Station marker is in feet, sketchup wants inches (sta * 12)

		pt1 = [0,0,0]
		pt2 = [0,0,0]

		for gore in 0..num_gores
			slice = 360 / num_gores		# Split envelope into slices based on number of gores
			degs = slice * gore
			radians = degs * Math::PI / 180
			x=origin[0] + radius*Math.cos(radians); 		# Determine location on circumference for panel edges
			y=origin[1] + radius*Math.sin(radians); 
			z=origin[2] + (height * 12)
			pt1=[x.round(3),y.round(3),z.round(3)]; 

			if @last_gore[gore] != nil
				pt3 = @old_last_gore
				pt4 = @last_gore[gore]
			end


			if (width !=  nil)
				arr = [pt1, pt2, pt3, pt4].compact.uniq

				if arr.size > 3  && pt2 != [0,0,0] && pt4 != [0,0,0]
		    			new_face = entities.add_face arr
					if @colorgrid[panel] != nil && @colorgrid[panel][gore] != nil
					     	new_face.material = "##{@color[@colorgrid[panel][gore]]}"
					else
					     	new_face.material = "white"

					end
					new_face.pushpull 0.125
				end
			end
			# Set the stuff for the next go around
			@old_last_gore = @last_gore[gore]
			@last_gore[gore] = pt1
		
			pt2 = pt1

		end
end



def draw_envelope

  # Get handles to our model and the Entities collection it contains.
  model = Sketchup.active_model
  entities = model.entities 
  @entities = entities
  # Create some variables.
  panel = 0
  @pt1 = [0, 0, 0]
  @pt2 = [0, 0, 0]
  @pt3 = [0, 0, 0]
  @pt4 = [0, 0, 0]  
  @last_sta = 0
  @last_width = 0
  @last_gore = Hash.new
  @colorgrid = Hash.new
  @last_gore[1] = [0,0,0]

  # Parse the output CSV from the Deering_Gore_pattern.xlsm file
  Paths.each do |path|
  	try = path + '/' + CSVName
  	if File.exists?(try)
		@EnvelopeCSV = try
		puts "Using: #{@EnvelopeCSV}"
  	end
  end


  if (@EnvelopeCSV) != nil
  	CSV.foreach(@EnvelopeCSV) do |row|	# First time around, get the color grid

		for idx in 0..row.size do 
			if row[idx] ==  "Color Chart Values"
				row.shift idx + 1
				@colorgrid[row.shift.to_i]=row	# Populate Color Grid with contents of line
			end
		end
	end
  	CSV.foreach(@EnvelopeCSV) do |row|
		sta = row[2].to_f
		radius = row[3].to_f
		circumference = row[5].to_f
		width = row[6].to_f
		height = row[37].to_f
		if (sta != 0 && radius != 0 && width != 0) 
			if width > 0 
				num_gores = (circumference / width).round
				ratio = sta / width
			end
			
			puts "Station #{sta.round(2)}ft Radius #{radius.round(2)}in Width #{width.round(2)}in Height #{height.round(2)}in Gores: #{num_gores}"
		
			centerpoint = Geom::Point3d.new(0,0,height * 12)
			vector = Geom::Vector3d.new 0,0,1
		 	vector2 = vector.normalize!
			if radius == 0 
				radius = 1
			else
			   radius = radius * 12
			end
#			panel = panel + 1
#			draw_panel_disc(radius, sta, height, width, num_gores, panel )

                # Figure where fabric edges would be
#
               @fabsize = 60
#
               @mid = (@last_sta * 12).to_i / @fabsize
               @curmid = (sta * 12).to_i / @fabsize
               @widratio = width / sta
               @heightratio = height / sta
               @width = @mid * @fabsize * @widratio / 12       
               @height = @mid * @fabsize * @heightratio / 12   
               #puts "Last Sta: #{@last_sta} LastMid: #{@mid * @fabsize / 12} Next: #{sta} CurMid: #{@curmid * @fabsize /12} Width: #{@width} Ratio: #{@ratio.round(2)}"
#       
               if (@curmid != @mid)    
                       panel = panel + 1
                       draw_panel_disc(radius, @curmid, @height, @width, num_gores, panel)
               end
#





			@last_sta = sta
			@last_width = width
			@last_height = height
		end
	  end
  end
end
