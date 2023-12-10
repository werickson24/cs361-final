#!/usr/bin/env ruby
require 'json'

class Track

  def initialize(segments, name: nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    @segments = segment_objects
  end

  def get_json_object()
    #track_json = {}
    #utterly break the code since this doesnt parse yet
    return({"Track":"Placeholder"})
    
    j = '{'
    j += '"type": "Feature", '
    if @name != nil
      j+= '"properties": {'
      j += '"title": "' + @name + '"'
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j +='"coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
        tsj += ']'
      end
      j+=tsj
      j+=']'
    end
    j + ']}}'
    
    # TEMPORARY HACK SINCE WE REFACTORED OUT OF ORDER OOPS
    return(JSON.parse(j))
  end
  
end

class TrackSegment

  attr_reader :coordinates
  
  def initialize(coordinates)
    @coordinates = coordinates
  end
  
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
  
end

class Waypoint

  attr_reader :point, :name, :type

  def initialize(point, name=nil, type=nil)
    @point = point
    @name = name
    @type = type
  end

  def get_json_object()
  #possible next step, Make get json return a ruby object of json structure, and have to_json called on it elsewhere.
  
    waypoint_json = {}
    waypoint_json['type'] = "Feature"
    
    coordinates = [@point.lon, @point.lat]
    coordinates.append(@point.ele) if @point.ele
    
    geometry = {}
    geometry['type'] = "Point"
    geometry['coordinates'] = coordinates
    waypoint_json['geometry'] = geometry
    
    if name or type
      properties = {}
      properties['title'] = name if name
      properties['icon'] = type if type
      waypoint_json['properties'] = properties
    end
    
    return waypoint_json#.to_json
  end                                                                             
end

class World

  def initialize(name, features)
    @name = name
    @features = features
  end
  
  def add_feature(f)
    @features.append(f)
  end

  def to_geojson()
    world_json = {}
    world_json['type'] = "FeatureCollection"
    
    features_json = []
    @features.each do |f|
      features_json.append(f.get_json_object)
    end
  
    world_json['features'] = features_json
    
    return world_json.to_json
  end
  
end

def main()

  waypoint1 = Waypoint.new(Point.new(-121.5, 45.5, 30), "home", "flag")
  waypoint2 = Waypoint.new(Point.new(-121.5, 45.6, nil), "store", "dot")
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track1 = Track.new([ts1, ts2], name: "track 1")
  track2 = Track.new([ts3], name: "track 2")

  world = World.new("My Data", [waypoint1, waypoint2, track1, track2])

  puts world.to_geojson()
  
end

if File.identical?(__FILE__, $0)

  main()
  
end

