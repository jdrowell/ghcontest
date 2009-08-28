#!/usr/bin/ruby -rubygems

require 'ruby-debug'

class GHContest
  attr_accessor :uhash, :uarray, :users, :repos

  def initialize
    #read_data; read_users; dump_data
    load_data; crunch
  end

  def read_data
    print "Reading data\n"

    f = File.open('download/data.txt')

    @uhash = {}
    @uarray = {}
    @repos = {}

    #lines = 500

    while !f.eof? do
      line = f.readline
      user, repo = line.chomp.split(':').map { |x| x.to_i } 

      @uhash[user] = {} unless @uhash.has_key?(user)
      @uhash[user].merge!({ repo => true })

      @repos[repo] = {} unless @repos.has_key?(repo)
      @repos[repo].merge!({ user => true })

      #if repos = uarray.has_key?(user)
      #  uarray[user].push(repo)
      #else
      #  uarray[user] = [ repo ]
      #end
      #lines -= 1
      #break if lines == 0
    end

    f.close
  end

  def read_users
    print "Reading users\n"

    f = File.open('download/test.txt')
    @users = {}

    while !f.eof? do
      line = f.readline
      user = line.chomp.map { |x| x.to_i }[0]
      @users[user] = []
    end

    f.close
  end

  def dump_data
    print "Writing data\n"

    f = File.open('data.marshal', 'w+')
    Marshal.dump(@uhash, f)
    f.close

    f = File.open('repos.marshal', 'w+')
    Marshal.dump(@repos, f)
    f.close

    f = File.open('users.marshal', 'w+')
    Marshal.dump(@users, f)
    f.close
  end

  def load_data
    print "Loading data\n"

    f = File.open('data.marshal')
    @uhash = Marshal.load(f)
    f.close

    f = File.open('repos.marshal')
    @repos = Marshal.load(f)
    f.close

    f = File.open('users.marshal')
    @users = Marshal.load(f)
    f.close
  end

  def crunch
    print "Crunching\n"
    popular = @repos.sort_by { |x| -x[1].size }[0, 50]
    res = popular.map { |x| x[0]}
    f = File.open('results.txt', 'w+')
    @users.each_pair do |user, empty|
      #debugger
      if user_hash = @uhash[user]
        #debugger
        ures = (res - user_hash.keys)[0, 10]
      else
        ures = res[0, 10]
      end
      f.write "#{user}:#{ures.join(',')}\n"
    end
    f.close
    #debugger
  end 
end

contest = GHContest.new

#debugger
#print "end"

