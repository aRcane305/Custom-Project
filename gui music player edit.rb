# frozen_string_literal: true

# import the necessary  libraries
require 'rubygems'
require 'gosu'

# set global constants for window dimensions and text offset
WINDOW_WIDTH = 1500
WINDOW_HEIGHT = 1050
TRACK_TEXT_X_OFFSET = 900
TRACK_TEXT_Y_OFFSET = 50
ALBUM_SIZE = 200
ALBUM_SPACING = 50
ALBUM_START_X = 100
ALBUM_START_Y = 100
ALBUM_COLUMNS = 3
# window background global constants
TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
SEMI_TRANSPARENT_TOP_COLOR = Gosu::Color.new(0x20C0C0C0)

# class definition for Album and attributes
class Album
  attr_accessor :album_title, :album_artist, :album_record_label, :album_cover, :album_year, :album_genre, :album_tracks

  def initialize(album_title, album_artist, album_record_label, album_cover, album_year, album_genre)
    # instance variables
    @album_title = album_title
    @album_artist = album_artist
    @album_record_label = album_record_label
    @album_cover = album_cover
    @album_year = album_year.to_i
    @album_genre = album_genre
    @album_tracks = []
  end

  def load_tracks_from_file(album_file)
    track_count = album_file.gets.to_i
    index = 0
    while index < track_count
      track_name = album_file.gets.chomp
      track_location = album_file.gets.chomp
      track_duration = album_file.gets.chomp
      track = Track.new(track_name, track_location, track_duration)
      @album_tracks << track
      index += 1
    end
  end
end

# class for album artwork
class ArtWork
  attr_accessor :bmp

  def initialize(file)
    @bmp = Gosu::Image.new(file)
  end
end

# module with Genre enumerations and corresponding names
module Genre
  # integer assignment for genres
  POP, DANCE, HIP_HOP_RAP, CLASSIC, JAZZ, SOUL, ROCK, ALTERNATIVE_INDIE = *1..8
  # array with the string representations of each genre
  GENRE_NAMES = ['Null', 'Pop', 'Dance', 'Hip-Hop Rap', 'Classic', 'Jazz', 'Soul', 'Rock', 'Alternative Indie'].freeze
end

# class definition for Track and its attributes
class Track
  attr_accessor :track_name, :track_location, :track_duration

  def initialize(track_name, track_location, track_duration)
    # instance variables
    @track_name = track_name
    @track_location = track_location
    @track_duration = track_duration.to_i
  end
end

# module for z-order layers for Gosu
module ZOrder
  BACKGROUND, PLAYER, UI_BACKGROUND, UI = *0..3
end

# code for music player window
class MusicPlayerMain < Gosu::Window
  # runs these during the render period
  def initialize
    # window size, window caption and fullscreen arguments
    super(WINDOW_WIDTH, WINDOW_HEIGHT, false)
    self.caption = 'Saadify'
    # font setup
    @primary_font = Gosu::Font.new(23, name: 'Aileron-Bold.ttf')
    @secondary_font = Gosu::Font.new(30, name: 'SF-Pro-Display-Regular.ttf')
    # initialize instance variables
    @current_album = nil
    @albums = read_in_albums
    print_albums_to_console
  end

  # read album count from file
  def album_count(album_file)
    album_file.gets.to_i
  end

  # read in albums information from file
  def read_in_albums
    album_file = File.open('albums.txt', 'r')
    total_albums = album_count(album_file)
    read_albums_from_file(album_file, total_albums)
  end

  # read in album from file, then load in the tracks
  def load_album(album_file)
    # debug
    # puts 'Debug: loading album'
    album_title = album_file.gets.chomp
    album_artist = album_file.gets.chomp
    album_record_label = album_file.gets.chomp
    album_cover_path = album_file.gets.chomp
    album_cover = ArtWork.new(album_cover_path)
    album_year = album_file.gets.chomp
    # checks genre
    genre = album_file.gets.chomp.to_i
    is_valid_genre = genre >= 1 && genre < Genre::GENRE_NAMES.length
    if is_valid_genre
      album_genre = Genre::GENRE_NAMES[genre]
    else
      error_message = "Invalid genre number: #{genre}"
      raise(error_message)
    end
    album = Album.new(album_title, album_artist, album_record_label, album_cover, album_year, album_genre)
    album.load_tracks_from_file(album_file)
    album
  end

  # reads all albums from file
  def read_albums_from_file(album_file, total_albums)
    # debug
    # puts 'Debug: loading albums'
    @albums = []
    index = 0
    while index < total_albums
      album = load_album(album_file)
      @albums[index] = album
      index += 1
    end
    # debug
    # puts "Debug: #{@albums.inspect}"
    @albums
  end

  # print loaded albums to console for debugging
  def print_albums_to_console
    puts "Loaded #{@albums.length} Albums:"
    index = 0
    while index < @albums.length
      album = @albums[index]
      puts "Album #{index + 1} - Artist: #{album.album_artist}, Name: #{album.album_title}, Label: #{album.album_record_label}, Year: #{album.album_year}, Genre: #{album.album_genre}, Tracks: #{album.album_tracks.length}"
      index += 1
    end
  end

  def seconds_to_minutes_seconds(seconds)
    minutes = seconds/60
    remaining_seconds = seconds % 60
    format('%02d:%02d', minutes, remaining_seconds)
  end

  # method to check for clicks within a rectangle
  def area_clicked(leftX, topY, rightX, bottomY)
    horizontal_boundary = (mouse_x >= leftX) && (mouse_x <= rightX)
    vertical_boundary = (mouse_y >= topY) && (mouse_y <= bottomY)

    x_coord = horizontal_boundary
    y_coord = vertical_boundary

    x_coord && y_coord
  end

  # display tracks for selected album onto window
  def display_tracks(tracks)
    @tracks = tracks
    index = 0
    while index < @tracks.length
      track_name = @tracks[index].track_name
      seconds = @tracks[index].track_duration
      duration = seconds_to_minutes_seconds(seconds)
      y_coord = TRACK_TEXT_Y_OFFSET + (index * 40)
      @primary_font.draw_text(track_name, TRACK_TEXT_X_OFFSET + 50, y_coord, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      @primary_font.draw_text("#{index + 1}.", TRACK_TEXT_X_OFFSET, y_coord, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      @primary_font.draw_text(duration, 1400, y_coord, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      index += 1
    end
  end



  # plays selected track
  def playTrack(track_index)
    if @tracks && @tracks[track_index]
      track = @tracks[track_index]
      @song = Gosu::Song.new(track.track_location)
      @song.play(false)

      if @current_album
        @now_playing_message = "Now playing: #{track.track_name}" +
          "\n#{@current_album.album_artist} - #{@current_album.album_title}"
      else
        @now_playing_message = "Now playing: #{track.track_name}"
      end
    end
  end

  def draw_background
    draw_quad(0, 0, TOP_COLOR, width, 0, TOP_COLOR, 0, height, BOTTOM_COLOR, width, height, BOTTOM_COLOR,
              ZOrder::BACKGROUND)
  end

  # Draw a semi-transparent rectangle
  def draw_translucent_rectangle
    # Define the coordinates of the rectangle
    left_x = 910   # Left X coordinate
    top_y = 30     # Top Y coordinate
    right_x = 1480 # Right X coordinate
    bottom_y = 730 # Bottom Y coordinate

    # Draw the quad with the translucent color
    draw_quad(
      left_x, top_y, SEMI_TRANSPARENT_TOP_COLOR,
      right_x, top_y, SEMI_TRANSPARENT_TOP_COLOR,
      left_x, bottom_y, SEMI_TRANSPARENT_TOP_COLOR,
      right_x, bottom_y, SEMI_TRANSPARENT_TOP_COLOR,
      ZOrder::PLAYER # Use a ZOrder layer for the UI background
    )
  end

  # draw the album covers from the paths stored in albums array
  def draw_albums
    album_spacing = ALBUM_SPACING
    album_cover_size = ALBUM_SIZE
    index = 0

    while index < @albums.length
      album = @albums[index]
      col = index % ALBUM_COLUMNS
      row = index / ALBUM_COLUMNS

      x_coord = ALBUM_START_X + (col * (album_cover_size + album_spacing))
      y_coord = ALBUM_START_Y + (row * (album_cover_size + album_spacing))

      scale_x = album_cover_size.to_f / album.album_cover.bmp.width
      scale_y = album_cover_size.to_f / album.album_cover.bmp.height

      album.album_cover.bmp.draw(x_coord, y_coord, ZOrder::UI_BACKGROUND, scale_x, scale_y)
      @primary_font.draw_text(album.album_title, x_coord,y_coord + ALBUM_SIZE, ZOrder::UI_BACKGROUND, 0.8, 0.8, Gosu::Color::BLACK)
      @secondary_font.draw_text(album.album_artist, x_coord,y_coord + ALBUM_SIZE + 15, ZOrder::UI_BACKGROUND, 0.5, 0.5, Gosu::Color::BLACK)
      index += 1
    end

    def draw_debug
      @secondary_font.draw_text("Mouse X: #{mouse_x.round}", 30, 970, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
      @secondary_font.draw_text("Mouse Y: #{mouse_y.round}", 30, 990, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end

  # gosu function to loop functions
  def update; end

  # main gosu drawing function
  def draw
    draw_background
    draw_albums
    draw_debug
    display_tracks(@tracks) if @tracks
    return unless @now_playing_message
    draw_translucent_rectangle
    @secondary_font.draw_text(@now_playing_message, 500, 900, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
  end

  # mouse cursor should be visible
  def needs_cursor? = true

  # detect and handle mouse click events
  def button_down(id)
    case id
    when Gosu::MsLeft
      index = 0
      while index < @albums.length
        album = @albums[index]
        spacing = ALBUM_SPACING
        width = ALBUM_SIZE
        height = ALBUM_SIZE

        x_coord = ALBUM_START_X + ((index % ALBUM_COLUMNS) * (width + spacing))
        y_coord = ALBUM_START_X + ((index / ALBUM_COLUMNS) * (height + spacing))

        if area_clicked(x_coord, y_coord, x_coord + width, y_coord + height)
          @tracks = album.album_tracks
          @current_album = album
          break
        end

        index += 1
      end

      if @tracks
        track_index = 0
        @now_playing_message = ''

        while track_index < @tracks.length
          track = @tracks[track_index]
          track_x_coord = TRACK_TEXT_X_OFFSET + 50
          track_y_coord = TRACK_TEXT_Y_OFFSET + (track_index * 40)
          track_height = 30

          if (mouse_x >= track_x_coord) &&
            (mouse_x <= track_x_coord + @primary_font.text_width(track.track_name)) &&
            (mouse_y >= track_y_coord) &&
            (mouse_y <= track_y_coord + track_height)

            playTrack(track_index)
            break
          end

          track_index += 1
        end
      end
    end
  end
end

MusicPlayerMain.new.show if __FILE__ == $PROGRAM_NAME
