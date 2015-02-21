!!! Hockey DB in Ruby

```
bundle install
ruby loadit.rb
sqlite3 hockeydb.sqlite3
```

Then, go nuts:

```
select players.name, max(goals) from players 
inner join teams on teams.id = players.team_id 
where teams.city = 'Chicago';
```