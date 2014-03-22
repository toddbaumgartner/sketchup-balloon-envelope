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

def draw_panel_disc(radius, height, num_gores,panel)
		entities = @entities
		circum = radius * 2 * Math::PI	
		z = 0
		origin = [0,0,200]
		@pt2 = @pt1		# Use coordinates from last panel as starting points
		@pt3 = @pt4

		pt1 = [0,0,0]
		pt2 = [0,0,0]

		for gore in 0..num_gores
			slice = 360.0 / num_gores		# Split envelope into slices based on number of gores- Use float instead of integer
			degs = slice * gore
			radians = degs * Math::PI / 180
			x=origin[0] + radius*Math.cos(radians); 		# Determine location on circumference for panel edges
			y=origin[1] + radius*Math.sin(radians); 
			z=origin[2] + (height)
			pt1=[x.round(3),y.round(3),z.round(3)]; 

			if @last_gore[gore] != nil
				pt3 = @old_last_gore
				pt4 = @last_gore[gore]
			end

			if (radius !=  0)
				arr = [pt1, pt2, pt3, pt4].compact.uniq

				if arr.size > 3  && pt2 != [0,0,0] && pt4 != [0,0,0]
		    			new_face = entities.add_face arr
					if @colorgrid[panel] != nil && @colorgrid[panel][gore] != nil
					     	new_face.material = "##{@color[@colorgrid[panel][gore]]}"
					else
          new_face.material = "white"

					end
					new_face.pushpull 0.01
				end
			end
			# Set the stuff for the next go around
			@old_last_gore = @last_gore[gore]
			@last_gore[gore] = pt1
		
			pt2 = pt1

#                 coordinates = [x, y, z]
#                 model = Sketchup.active_model
#                 entities = model.entities
#                 point = Geom::Point3d.new coordinates
#                 text = entities.add_text "#{radius.round(2)} #{z.round(2)}", point
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
  @colorgrid = Hash.new
  @last_gore = Hash.new
  @last_gore[1] = [0,0,0]
  last_sta = 0
  last_rad = 0
  lastradratio = 1
  radratio = 1


  # With four params, it shows a drop down box for prompts that have
  # pipe-delimited lists of options. In this case, the Gender prompt
  # is a drop down instead of a text box.
  #  prompts = ["What is your Name?", "What is your Age?", "Panel Shape"]
  #  defaults = ["Enter name", "", "Male"]
  #  list = ["", "", "Natural Boundries|Fabric Width"]
  prompts = ["Panel Shape"]
  defaults = ["Natural Boundries"]
  list = ["Natural Boundries|Fabric Width"]
  input = UI.inputbox(prompts, defaults, list, "What are we doing today?")
  if input != nil
    shape = input[0]
  end

  model.rendering_options["EdgeDisplayMode"] =1    # 0 to hide edges
  model.rendering_options["SilhouetteWidth"] = 0

  @EnvelopeCSV = UI.openpanel("Open Envelope CSV File", "c:/", "*.csv")

  # Parse the output CSV from the Deering_Gore_pattern.xlsm file
  #  Paths.each do |path|
  #  	try = path + '/' + CSVName
  #  	if File.exists?(try)
  #		@EnvelopeCSV = try
  #		puts "Using: #{@EnvelopeCSV}"
  #  	end
  #  end


  if (@EnvelopeCSV) != nil
    UI.messagebox("Here goes.. Sketchup may take a minute to render")
    status = model.start_operation('Draw Envelope', true,true)
#
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
		  height = height * 12    # Lets use inches
			if radius == 0 
        radius = 0.01 
			else
			 radius = radius * 12   # Same here
			end
	
      if width == 0 
        num_gores = 8
        width= 0.01

      end
		  if (sta != 0 && radius != 0 && width != 0) 
			  if width > 0 
				  num_gores = (circumference / width).round
			  end
		
			  centerpoint = Geom::Point3d.new(0,0,height)
			  vector = Geom::Vector3d.new 0,0,1
		 	  vector2 = vector.normalize!
		    # Fork in the road here
		    # 
		    if shape == "Natural Boundries"
			    panel = panel + 1

			    draw_panel_disc(radius, height, num_gores, panel)
		    else
         	# Figure where fabric edges would be
       		@fabsize = 60         # Width of fabric 
      		@mid = (last_sta * 12).to_i / @fabsize     # Find last panel edge based on last station marker
	       	@curmid = (sta * 12).to_i / @fabsize        # Find current panel edge based on current station marker
          if (last_sta != 0 ) 
         		lastradratio = last_rad / last_sta       # Theres probably a better way to do this
          end
       		radratio = radius / sta                 # Theres probably a better way to do this
       		@heightratio = height / sta           # Ditto
          @avgradratio = (lastradratio + radratio)  / 2.0
       		@radius = @mid * @fabsize / 12 * @avgradratio 
       		@height = @mid * @fabsize * @heightratio / 12   
         		if (@curmid != @mid)    
              	panel = panel + 1
                draw_panel_disc(@radius, @height, num_gores, panel)
                #
                #puts ">Station #{@mid * @fabsize / 12}, Radius #{@radius.round(2)} Width #{@width.round(2)} Height #{@height}, #{num_gores}, #{panel}"
         		end
		    end

        puts "Panel #{panel} Station #{sta.round(2)} Radius #{radius.round(2)} Height #{height.round(2)} Gores #{num_gores}"
			  last_sta = sta
			  last_rad = radius
		  end
      model.commit_operation() 

	  end
  end
end
