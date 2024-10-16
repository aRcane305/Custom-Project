# frozen_string_literal: true
require_relative 'z0rder'
require_relative 'genre'
require_relative 'album'
require_relative 'track'
require_relative 'load_albums'
require_relative 'display_albums'
require_relative 'artwork'
require 'rubygems'
require 'gosu'

WINDOW_WIDTH = 1600
WINDOW_HEIGHT = 900
TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

# Put your record definitions here

class MusicPlayerMain < Gosu::Window
  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT, false)
    self.caption = 'Music Player'
    @music_player_font = Gosu::Font.new(26)
    # Reads in an array of albums from a file and then prints all the albums in the
    # array to the terminal
    read_in_albums
    display_loaded_albums
  end

  # Put in your code here to load albums and tracks

  # Draws the artwork on the screen for all the albums

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false

  def area_clicked(leftX, topY, rightX, bottomY)
    # complete this code
  end

  # Takes a String title and an Integer ypos
  # You may want to use the following:
  def display_track(title, ypos)
    @track_font.draw(title, TrackLeftX, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
  end

  # Takes a track index and an Album and plays the Track from the Album

  def playTrack
    #
  end

  # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
  def draw_background
    draw_quad(0, 0, TOP_COLOR, width, 0, TOP_COLOR, 0, height, BOTTOM_COLOR, width, height, BOTTOM_COLOR,
              ZOrder::BACKGROUND)
  end

  def draw_albums_page_1
    album_y_limit = 35
    album_x_limit = 150
    album_size = 350
    album_spacing = 25

    album_cover_1 = ArtWork.new(File.join(__dir__,"/images/Another_Friday_Night.jpg"))
    album_cover_2 = ArtWork.new(File.join(__dir__,"/images/ASTROWORLD.jpg"))
    album_cover_3 = ArtWork.new(File.join(__dir__,"/images/Little_Dark_Age.jpg"))
    album_cover_4 = ArtWork.new(File.join(__dir__,"/images/Thriller.jpg"))

    album_cover_1.bmp.draw(album_x_limit, album_y_limit)
    album_cover_2.bmp.draw(album_x_limit + album_size + album_spacing, album_y_limit)
    album_cover_3.bmp.draw(album_x_limit, album_y_limit + album_spacing + album_size)
    album_cover_4.bmp.draw(album_x_limit + album_size + album_spacing, album_y_limit + album_spacing + album_size)
  end

  def draw_albums_page_2
    album_y_limit = 35
    album_x_limit = 150
    album_size = 350
    album_spacing = 25

    album_cover_1 = ArtWork.new(File.join(__dir__,"/images/Goodbye_Girl.jpg"))

    album_cover_1.bmp.draw(album_x_limit, album_y_limit)
  end

  def draw_albums
    # function to draw either draw_albums_page based on mouse click
  end

  def update; end

  # Draws the album images and the track list for the selected album

  def draw
    draw_background
    draw_albums_page_1
  end

  def needs_cursor? = true

  # If the button area (rectangle) has been clicked on change the background color
  # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
  # you will learn about inheritance in the OOP unit - for now just accept that
  # these are available and filled with the latest x and y locations of the mouse click.

  def button_down(id)
    case id
    when Gosu::MsLeft

    end
  end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $PROGRAM_NAME
