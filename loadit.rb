require 'rubygems'
require 'sqlite3'
require 'csv'

dir = File.expand_path(File.dirname(__FILE__))
db_filename = File.join(dir, 'hockey.sqlite3')
File.delete(db_filename) if File.exists?(db_filename)

db = SQLite3::Database.new db_filename

# Schema
db.execute <<-SQL
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
    stanley_cups integer(11)
  );
SQL

db.execute <<-SQL
  create table seasons (
    id INTEGER PRIMARY KEY ASC,
    team_id integer(11),
    year varchar(30),
    team_name varchar(30),
    games_played integer(11), 
    wins integer(11), 
    losses integer(11), 
    ties integer(11), 
    overtime_losses integer(11), 
    points integer(11), 
    result varchar(30)
  );
SQL

db.execute <<-SQL
  create table players (
    id INTEGER PRIMARY KEY ASC,
    team_id integer(11),
    name varchar(30),
    from_year varchar(30),
    to_year varchar(30),
    position varchar(30),
    games_played integer(11),
    goals integer(11),
    assists integer(11),
    points integer(11),
    plus_minus integer(11),
    penalty_minutes integer(11),
    game_winning_goals integer(11)
  );
SQL

# Inserts
team_insert = <<-SQL
  insert into teams 
    (city, name, from_year, to_year, games_played, 
     wins, losses, ties, overtime_losses,
     years_in_playoffs, division_titles, 
     conference_titles, stanley_cups) 
    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
SQL

season_insert = <<-SQL
  insert into seasons
    (team_id, year, team_name, games_played, wins, 
     losses, ties, overtime_losses, points, result)
    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
SQL

player_insert = <<-SQL
  insert into players
    (team_id, name, from_year, to_year, position,
     games_played, goals, assists, points, plus_minus, 
     penalty_minutes, game_winning_goals)
    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
SQL

# Team Data
teams = [['Anaheim', 'Ducks', 'ANA'],
         ['Arizona', 'Coyotes', 'PHX'],
         ['Boston', 'Bruins', 'BOS'],
         ['Buffalo', 'Sabres', 'BUF'],
         ['Calgary', 'Flames', 'CGY'],
         ['Carolina', 'Hurricanes', 'CAR'],
         ['Chicago', 'Blackhawks', 'CHI'],
         ['Colorado', 'Avalanche', 'COL'],
         ['Columbus', 'Blue Jackets', 'CBJ'],
         ['Dallas', 'Stars', 'DAL'],
         ['Detroit', 'Red Wings', 'DET'],
         ['Edmonton', 'Oilers', 'EDM'],
         ['Florida', 'Panthers', 'FLA'],
         ['Los Angeles', 'Kings', 'LAK'],
         ['Minnesota', 'Wild', 'MIN'],
         ['Montreal', 'Canadiens', 'MTL'],
         ['Nashville', 'Predators', 'NSH'],
         ['New Jersey', 'Devils', 'NJD'],
         ['New York', 'Islanders', 'NYI'],
         ['New York', 'Rangers', 'NYR'],
         ['Ottawa', 'Senators', 'OTT'],
         ['Philadelphia', 'Flyers', 'PHI'],
         ['Pittsburgh', 'Penguins', 'PIT'],
         ['San Jose', 'Sharks', 'SJS'],
         ['St. Louis', 'Blues', 'STL'],
         ['Tampa Bay', 'Lightning', 'TBL'],
         ['Toronto', 'Maple Leafs', 'TOR'],
         ['Vancouver', 'Canucks', 'VAN'],
         ['Washington', 'Capitals', 'WSH'],
         ['Winnipeg', 'Jets', 'WPG']]

# Load It
team_file = CSV.read(File.join(dir, 'data', 'teams.csv'))
team_file.shift
team_file.each do |row|
  # Franchise,Lg,From,To,Yrs,GP,W,L,T,OL,PTS,PTS%,Yrs Plyf,Div,Conf,Champ,St Cup
  puts "Loading #{row.first}"
  team = teams.select { |team| [team[0], team[1]].join(' ') == row.first }.first
  code = team[2]
  db.execute team_insert, team[0], 
                          team[1], 
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
  team_id = db.last_insert_row_id
  team_name = row.first

  # Season,Lg,Team,GP,W,L,T,OL,PTS,PTS%,SRS,SOS,Finish,Playoffs,Coaches
  puts "- Seasons"
  season_file = CSV.read(File.join(dir, 'data', "teams_#{code}__#{code}.csv"))
  season_file.shift(2)
  season_file.each do |row|
    db.execute season_insert, team_id, 
                              row[0],
                              team_name,
                              row[3],
                              row[4],
                              row[5],
                              row[6],
                              row[7],
                              row[8],
                              row[13]
  end

  # Rk,Player,From,To,Yrs,Pos,GP,G,A,PTS,+/-,PIM,EV,PP,SH,GW,EV,PP,SH,S,S%,TOI,ATOI
  # (team_id, name, from_year, to_year, position,
  #    games_played, goals, assists, points, plus_minus, 
  #    penalty_minutes, game_winning_goals)
  puts "- Players"
  players_file = CSV.read(File.join(dir, 'data', "teams_#{code}_skaters_skaters.csv"))
  players_file.shift(2)
  players_file.each do |row|
    if row[0].to_i > 0
      db.execute player_insert, team_id,
                                row[1],
                                row[2],
                                row[3],
                                row[5],
                                row[6],
                                row[7],
                                row[8],
                                row[9],
                                row[10],
                                row[11],
                                row[15]
    end
  end
end
