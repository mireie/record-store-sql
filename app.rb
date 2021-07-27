require("sinatra")
require("sinatra/reloader")
require("./lib/album")
require("./lib/song")
require("./lib/artist")
require("pry")
require("pg")
also_reload("lib/**/*.rb")

DB = PG.connect({ :dbname => "record_store", :password => "epicodus" })

get("/") do
  @albums = Album.all
  @albums.sort_by! { |album| album.name.downcase }
  @artists = Artist.all
  @artists.sort_by! { |artist| artist.name.downcase }
  erb(:index)
end

get("/albums") do
  @albums = Album.all
  @albums.sort_by! { |album| album.name.downcase }
  erb(:albums)
end

get("/albums/new") do
  erb(:new_album)
end

post("/albums") do
  album = Album.new({ :name => params[:album_name], :id => nil, :release_year => params[:release_year] })
  album.save()
  redirect to("/albums")
end

get("/albums/:id") do
  @album = Album.find(params[:id].to_i())
  if @album
    erb(:album)
  else
    redirect to("/")
  end
end

get("/albums/:id/edit") do
  @album = Album.find(params[:id].to_i())
  if @album
    erb(:edit_album)
  else
    redirect to("/")
  end
end

patch("/albums/:id") do
  @album = Album.find(params[:id].to_i())
  @album.update(params[:name])
  redirect to("/albums")
end

delete ("/albums/:id") do
  @album = Album.find(params[:id].to_i())
  @album.delete()
  redirect to("/albums")
end

get ("/albums/:id/songs/:song_id") do
  if @song
    @song = Song.find(params[:song_id].to_i())
    erb(:song)
  else
    redirect to("/albums/#{params[:id]}")
  end
end

post ("/albums/:id/songs") do
  @album = Album.find(params[:id].to_i())
  song = Song.new({ :name => params[:song_name], :album_id => @album.id, :id => nil })
  song.save()
  erb(:album)
end

patch ("/albums/:id/songs/:song_id") do
  @album = Album.find(params[:id].to_i())
  song = Song.find(params[:song_id].to_i())
  song.update(params[:name], @album.id)
  erb(:album)
end

delete ("/albums/:id/songs/:song_id") do
  song = Song.find(params[:song_id].to_i())
  song.delete
  @album = Album.find(params[:id].to_i())
  erb(:album)
end

get ("/albums/:id/artists") do
  erb(:artists)
end

get("/artists") do
  @artists = Artist.all
  @artists.sort_by! { |artist| artist.name.downcase }
  erb(:artists)
end

get("/artists/:id") do
  @artist = Artist.find(params[:id].to_i())
  if @artist
    erb(:artist)
  elsif params[:id] === "new"
    erb(:new_artist)
  else
    redirect to("/")
  end
end

post("/artists") do
  artist = Artist.new({ :name => params[:artist_name], :id => nil })
  artist.save()
  redirect to("/artists")
end

get("/artists/:id/edit") do
  @artist = Artist.find(params[:id].to_i())
  if @artist
    erb(:edit_artist)
  else
    redirect to("/artists")
  end
end

patch("/artists/:id") do
  @artist = Artist.find(params[:id].to_i())
  @artist.update({ :name => params[:name].to_s })
  redirect to("/artists")
end

delete ("/artists/:id") do
  @artist = Artist.find(params[:id].to_i())
  @artist.delete()
  redirect to("/artists")
end

get("/artists/:id/add_album") do
  @artist = Artist.find(params[:id].to_i())
  if @artist
    erb(:add_album)
  else
    redirect to("/artists")
  end
end

post("/artists/:id/add_album") do
  @artist = Artist.find(params[:id].to_i())
  album = Album.new({ :name => params[:album_name], :id => nil })
  album.save()
  @artist.update({ :album_name => params[:album_name] })
  erb(:artist)
end
# get ("/albums/sort/:sort_method") do
#   @albums = Album.all
#   case params[:sort_method]
#   when "id"
#     @albums.sort_by! {|album| album.id}
#   when "release_year"
#     @albums.sort_by! {|album| album.release_year}
#   else
#     @albums.sort_by! {|album| album.name}
#   end
#   redirect to ("/")
# end
