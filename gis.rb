#!/usr/bin/env ruby
require 'json'

# Track manages an array of TrackSegments and the name of that track
class Track

  def initialize(segments: , name: nil)
    @name = name
    @segments = segments_to_tracksegments(segments)
  end
  
  def segments_to_tracksegments(segments)
    seg_array = []
    segments.each do |s|
      seg_array.append(track_segment(s))
    end
    return seg_array
  end
  
  # from my prior GIS experience, keeping track segments is important to how GIS software works, 
  # so isolating the class, and keeping the workflow the same without dependency injection seems like the best solution
  def track_segment(coordinates)
    TrackSegment.new(coordinates)
  end

  def get_json_object()
    track_json = {}
    track_json['type'] = "Feature"
    
    if @name
      title = {}
      title['title'] = @name
      track_json['properties'] = title
    end
    
    coordinates = []
    @segments.each do |s|
      coordinates.append(s.get_json_object)
    end
    
    geometry = {}
    geometry['type'] = "MultiLineString"
    geometry['coordinates'] = coordinates
    
    track_json['geometry'] = geometry

    return track_json
  end
  
end

# Track Segment handles a set of points
class TrackSegment

  attr_reader :coordinates
  
  def initialize(coordinates)
    @coordinates = coordinates
  end
  
  def get_json_object()
    segment = []
    coordinates.each do |c|
      point = c.get_json_object
      segment.append(point)
    end
    return segment
  end
  
end

# Point handles 3d and 2d coordinates in form decimal degrees
class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
  
  def get_json_object()
    coordinates = [@lon, @lat]
    coordinates.append(@ele) if @ele
    return coordinates
  end
  
end

# Waypoint handles a point and related information
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
    
    coordinates = @point.get_json_object
    
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

# World handles multiple types of features under a single name
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
  
  trackseg1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  trackseg2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  trackseg3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track1 = Track.new(segments: [trackseg1, trackseg2], name: "track 1")
  track2 = Track.new(segments: [trackseg3], name: "track 2")

  world = World.new("My Data", [waypoint1, waypoint2, track1, track2])

  puts world.to_geojson()
  
end

if File.identical?(__FILE__, $0)

  main()
  
end

