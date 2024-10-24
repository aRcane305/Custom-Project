# frozen_string_literal: true
require 'rubygems'
require 'gosu'

WINDOW_WIDTH = 1600
WINDOW_HEIGHT = 900
TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

# Put your record definitions here
class Album
  attr_accessor :album_title, :album_artist, :album_record_label, :album_cover, :album_year, :album_genre, :album_tracks

  def initialize(album_title, album_artist, album_record_label, album_cover, album_year, album_genre, album_tracks)
    @album_title = album_title
    @album_artist = album_artist
    @album_record_label = album_record_label
    @album_cover = album_cover
    @album_year = album_year
    @album_genre = album_genre
    @album_tracks = album_tracks
  end
end

class ArtWork
  attr_accessor :bmp

  def initialize(file)
    @bmp = Gosu::Image.new(file)
  end
end

module Genre
  POP, DANCE, HIP_HOP_RAP, CLASSIC, JAZZ, SOUL, ROCK, ALTERNATIVE_INDIE = *1..8

  GENRE_NAMES = ["Null", "Pop", "Dance", "Hip-Hop Rap", "Classic", "Jazz", "Soul", "Rock", "Alternative Indie"]
end

class Track
  attr_accessor :track_name, :track_location, :track_duration

  def initialize(track_name, track_location, track_duration)
    @track_name = track_name
    @track_location = track_location
    @track_duration = track_duration
  end
end

module ZOrder
  BACKGROUND, PLAYER, UI_BACKGROUND, UI = *0..3
end

class MusicPlayerMain < Gosu::Window
  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT, false)
    self.caption = 'Music Player'
    @music_player_font = Gosu::Font.new(20)
    # Reads in an array of albums from a file and then prints all the albums in the
    # array to the terminal
    @albums = read_in_albums
    display_loaded_albums
  end

  def album_count(album_file)
    album_file.gets.to_i
  end

  # points the functions towards the file directory
  # opens the file for reading
  def read_in_albums
    # read in the album information from chosen file
    album_file = File.open('albums.txt', 'r')
    total_albums = album_count(album_file)
    load_albums(album_file, total_albums)
  end

  # load a single track from the album file
  def load_track(album_file)
    # debug
    puts 'Debug: loading track'
    track_name = album_file.gets.chomp
    track_location = album_file.gets.chomp
    track_duration = album_file.gets.chomp
    Track.new(track_name, track_location, track_duration)
  end

  # loads an array of tracks from the album file
  def load_tracks(album_file)
    # debug
    puts 'Debug: loading tracks'
    # using @ makes it an instance variable, so it can be used in other functions
    tracks = []
    count = album_file.gets.to_i
    # debug
    puts "Debug: count = #{count}"
    index = 0
    while index < count
      track = load_track(album_file)
      tracks[index] = track
      index += 1
    end
    # debug
    puts "Debug: #{tracks.inspect}"
    tracks
  end

  # load an album from the album file
  def load_album(album_file)
    # debug
    puts 'Debug: loading album'
    album_title = album_file.gets.chomp
    album_artist = album_file.gets.chomp
    album_record_label = album_file.gets.chomp
    album_cover_path = album_file.gets.chomp
    album_cover = ArtWork.new(album_cover_path)
    album_year = album_file.gets.chomp.to_i
    genre = album_file.gets.chomp.to_i
    # || basically evaluates the right side if the left side returns nil
    # because the array is empty,
    # raise literally raises an exception
    # means the album.txt file has wrong strings
    album_genre = Genre::GENRE_NAMES[genre] || raise("Invalid genre number: #{genre}")
    # debug
    # puts "Debug: found album genre: #{album_genre}"
    album_tracks = load_tracks(album_file)
    # stores the variables in the class
    Album.new(album_title, album_artist, album_record_label, album_cover, album_year, album_genre, album_tracks)
  end

  # load an array of albums from the album file
  def load_albums(album_file, total_albums)
    # debug
    puts 'Debug: loading albums'
    @albums = []
    index = 0
    while index < total_albums
      album = load_album(album_file)
      @albums[index] = album
      index += 1
    end
    # debug
    puts "Debug: #{@albums.inspect}"
    @albums
  end

  def display_loaded_albums
    puts 'Loaded Albums:'
    index = 0
    while index < @albums.length
      album = @albums[index]
      # strip is needed, as items in the array are read in using gets,
      # there are \n after each gets and so ,Name would be printed in a new line
      # strip chomps down after the input
      # using gets.chomp in the loading phase is also an option
      puts "Album #{index + 1} - Artist: #{album.album_artist}, Name: #{album.album_title}, Label: #{album.album_record_label}, Year: #{album.album_year}, Genre: #{album.album_genre}, Tracks: #{album.album_tracks.length}"
      index += 1
    end
  end

  # Draws the artwork on the screen for all the albums

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false

  def area_clicked(leftX, topY, rightX, bottomY)
    x_coord = (mouse_x >= leftX) && (mouse_x <= rightX)
    y_coord = (mouse_y >= topY) && (mouse_y <= bottomY)
    return x_coord && y_coord
    # complete this code
  end

  # Takes a String title and an Integer ypos
  # You may want to use the following:
  def display_tracks(tracks)
    @tracks = tracks
    index = 0
    while index < @tracks.length
      track_name = @tracks[index].track_name
      ypos = 25 + index * 40
      @music_player_font.draw_text(track_name, 800, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
      index += 1
    end
  end

  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(track_index)
    if @tracks && @tracks[track_index]
      track = @tracks[track_index]
      track_location = track.track_location
    @song = Gosu::Song.new(track_location)
      @song.play(false)
    @now_playing_message = 'Now playing: ' + track.track_name
    end
    " "
  end

  # Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
  def draw_background
    draw_quad(0, 0, TOP_COLOR, width, 0, TOP_COLOR, 0, height, BOTTOM_COLOR, width, height, BOTTOM_COLOR,
              ZOrder::BACKGROUND)
  end

  def draw_albums
    start_x_coord = 150
    start_y_coord = 50
    album_spacing = 25
    album_cover_size = 350
    columns = 2
    index = 0

    while index < @albums.length
      album = @albums[index]
      # Calculate the row and col based on the index
      col = index % columns
      row = index / columns

      # Calculate x and y coordinates based on the row and column
      x_coord = start_x_coord + col * (album_cover_size + album_spacing)
      y_coord = start_y_coord + row * (album_cover_size + album_spacing)

      # Draw the album artwork using its bmp accessor
      album.album_cover.bmp.draw(x_coord, y_coord, ZOrder::PLAYER, 1, 1)

      index += 1
    end
  end

  def update; end

  # Draws the album images and the track list for the selected album

  def draw
    draw_background
    draw_albums
    if @tracks
      display_tracks(@tracks)
    end
    if @now_playing_message
      @music_player_font.draw_text(@now_playing_message, 800, 600, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
    end
  end

  def needs_cursor? = true

  # If the button area (rectangle) has been clicked on change the background color
  # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
  # you will learn about inheritance in the OOP unit - for now just accept that
  # these are available and filled with the latest x and y locations of the mouse click.

  def button_down(id)
    case id
    when Gosu::MsLeft
      index = 0
      while index < @albums.length
        album = @albums[index]
        spacing = 15
        width = 375
        height = 375
        x_coord = 15 + (index % 2) * (width + spacing)
        y_coord = 15 + (index / 2) * (height + spacing)

        if area_clicked(x_coord, y_coord, x_coord + width, y_coord + height)
          @tracks = album.album_tracks
          break
        end
        index += 1
      end
      if @tracks
        track_index = 0
        @now_playing_message = ""
        while track_index < @tracks.length
          track = @tracks[track_index]
          track_x_coord = 800
          track_y_coord = 25 + track_index * 40
          track_height = 30
          if (mouse_x >= track_x_coord) && (mouse_x <= track_x_coord + @music_player_font.text_width(track.track_name)) && mouse_y >= track_y_coord && mouse_y <= track_y_coord + track_height
            playTrack(track_index)
            break
          end
          track_index += 1
        end
      else
      end
    end
  end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $PROGRAM_NAME
