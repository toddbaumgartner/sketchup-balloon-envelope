# Sketchup Envelope Drawing Thingee
# <todd.baumgartner@gmail.com> 3/20/2014
# Sorry for how awful this code is, I am still learning the API
# This one will read the output of Deering_Gore_Pattern
# Good Luck

require 'sketchup.rb'
require 'extensions.rb'

envelope_extension = SketchupExtension.new('Balloon Envelope Extension' , 'balloon_envelope/envelope.rb')
envelope_extension.version = '1.0'
envelope_extension.description = 'Draw Hot Air Balloon Envelope from Gore Spreadsheet.'
envelope_extension.creator = 'Todd Baumgartner <todd.baumgartner@gmail.com>'
Sketchup.register_extension(envelope_extension, true)
