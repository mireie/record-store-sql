class Artist
  attr_accessor :name
  attr_reader :id

  def initialize(attributes)
    attributes.each { |pair| instance_variable_set("@#{pair[0].to_s}", pair[1]) }
  end

  def self.all
    returned_artists = DB.exec("SELECT * FROM artists;")
    artists = []
    returned_artists.each() do |artist|
      name = artist.fetch("name")
      id = artist.fetch("id").to_i
      artists.push(Artist.new({ :name => name, :id => id }))
    end
    artists
  end

  def save
    result = DB.exec("INSERT INTO artists (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(artist_to_compare)
    self.name() == artist_to_compare.name()
  end

  def self.clear
    DB.exec("DELETE FROM artists *;")
  end

  def self.find(id)
    artist = DB.exec("SELECT * FROM artists WHERE id = #{id};").first
    if artist
      name = artist.fetch("name")
      id = artist.fetch("id").to_i
      Artist.new({ :name => name, :id => id })
    else
      false
    end
  end

  def update(attributes)
    if (attributes.has_key?(:name)) && (attributes.fetch(:name) != nil)
      @name = attributes.fetch(:name)
      DB.exec("UPDATE artists SET name = '#{@name}' WHERE id = #{@id};")
    elsif (attributes.has_key?(:album_name)) && (attributes.fetch(:album_name) != nil)
      album_name = attributes.fetch(:album_name)
      album = DB.exec("SELECT * FROM albums WHERE lower(name)='#{album_name.downcase}';").first
      if album != nil
        DB.exec("INSERT INTO albums_artists (album_id, artist_id) VALUES (#{album["id"].to_i}, #{@id});")
      end
    end
  end

  def albums
    albums = []
    results = DB.exec("SELECT album_id FROM albums_artists WHERE artist_id = #{@id};")
    results.each() do |result|
      album_id = result.fetch("album_id").to_i()
      album = DB.exec("SELECT * FROM albums WHERE id = #{album_id};")
      name = album.first().fetch("name")
      albums.push(Album.new({ :name => name, :id => album_id }))
    end
    albums
  end

  def delete
    DB.exec("DELETE FROM albums_artists WHERE artist_id = #{@id};")
    DB.exec("DELETE FROM artists WHERE id = #{@id};")
  end

  def self.find_by_album(alb_id)
    artists = []
    returned_artists = DB.exec("SELECT artist_id FROM albums_artists WHERE album_id = #{alb_id};")
    returned_artists.each do |artist|
      artist = DB.exec("SELECT name FROM artists WHERE id = #{artist.fetch("artist_id")};").first
      artists.push(artist.fetch("name"))
    end
    # binding.pry
    artists.join(", ")
  end
end

# returned_artists.each() do |artist|
#   name = artist.fetch("name")
#   id = artist.fetch("id").to_i
#   artists.push(Artist.new({ :name => name, :album_id => alb_id, :id => id }))
# end
# artists.join(",")