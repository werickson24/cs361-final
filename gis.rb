#!/usr/bin/env ruby
require 'json'

class Track

  def initialize(segments, name: nil)
    @name = name
    segment_objects = []
    #move this to a function later
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    @segments = segment_objects
  end

  def get_json_object()
    track_json = {}
    track_json['type'] = "Feature"
    
    if @name
      title = {}
      title['title'] = @name
      track_json['properties'] = title
    end
    
    #parse all segments and their points together into coordinate
    coordinates = []
    @segments.each do |s|
      segment = []
      s.coordinates.each do |c|
        point = [c.lon, c.lat]
        point.append(c.ele) if c.ele
        
        segment.append(point)
      end
      coordinates.append(segment)
    end
    
    geometry = {}
    geometry['type'] = "MultiLineString"
    geometry['coordinates'] = coordinates
    
    track_json['geometry'] = geometry

    return track_json
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
    
    return waypoint_json
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

