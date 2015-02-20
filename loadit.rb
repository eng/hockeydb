require 'rubygems'
require 'sqlite3'
require 'csv'

dir = File.expand_path(File.dirname(__FILE__))
db_filename = File.join(dir, 'test.db')
File.delete db_filename

db = SQLite3::Database.new db_filename

rows = db.execute <<-SQL
  create table teams (
    id INTEGER PRIMARY KEY ASC,
    city varchar(30),
    name varchar(30),
    from_year varchar(30),
    to_year varchar(30),
    games_played integer(11),
    wins integer(11),
    losses integer(11),
    ties integer(11),
    overtime_losses integer(11),
    years_in_playoffs integer(11),
    division_titles integer(11),
    conference_titles integer(11),
    league_titles integer(11),
    stanley_cups integer(11)
  );
SQL

cities = [['Anaheim', 'Ducks'],
         ['Arizona', 'Coyotes'],
         ['Boston', 'Bruins'],
         ['Buffalo', 'Sabres'],
         ['Calgary', 'Flames'],
         ['Carolina', 'Hurricanes'],
         ['Chicago', 'Blackhawks'],
         ['Colorado', 'Avalanche'],
         ['Columbus', 'Blue Jackets'],
         ['Dallas', 'Stars'],
         ['Detroit', 'Red Wings'],
         ['Edmonton', 'Oilers'],
         ['Florida', 'Panthers'],
         ['Los Angeles', 'Kings'],
         ['Minnesota', 'Wild'],
         ['Montreal', 'Canadiens'],
         ['Nashville', 'Predators'],
         ['New Jersey', 'Devils'],
         ['New York', 'Islanders'],
         ['New York', 'Rangers'],
         ['Ottawa', 'Senators'],
         ['Philadelphia', 'Flyers'],
         ['Pittsburgh', 'Penguins'],
         ['San Jose', 'Sharks'],
         ['St. Louis', 'Blues'],
         ['Tampa Bay', 'Lightning'],
         ['Toronto', 'Maple Leafs'],
         ['Vancouver', 'Canucks'],
         ['Washington', 'Capitals'],
         ['Winnipeg', 'Jets']]

teams = CSV.read(File.join(dir, 'data', 'teams.csv'))
teams.shift
teams.each do |row|
  # Franchise,Lg,From,To,Yrs,GP,W,L,T,OL,PTS,PTS%,Yrs Plyf,Div,Conf,Champ,St Cup
  puts "Building #{row.first}"
  city = cities.select { |city| [city.first, city.last].join(' ') == row.first }.first
  sql = <<-SQL
    insert into teams 
      (city, name, from_year, to_year, games_played, 
       wins, losses, ties, overtime_losses,
       years_in_playoffs, division_titles, 
       conference_titles, stanley_cups) 
      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  SQL
  db.execute sql, city.first, 
                  city.last, 
                  row[2], 
                  row[3], 
                  row[5], 
                  row[6], 
                  row[7], 
                  row[8], 
                  row[9],
                  row[12],
                  row[13],
                  row[14],
                  row[16]
end
