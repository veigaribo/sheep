@tool
class_name PointSampler2D
extends Node2D

# Each outer array will contain a polygon.
# Each inner array will a vertex of the polygon.
@export var polygons_vertices: Array# of PackedVector2Array

# Weight to assign to each polygon (should match the items in the outer
# vertex array). If empty, will default to all 1 (equal).
# Each polygon will be weighed by area in every case, however. If that is not
# desirable, maybe use different PointSampler2Ds for each one.
# By the way, this assumes the polygons do not intersect.
@export var biases: Array# of float

@export var test: bool

var polygons: Array# of Polygon

var _last_polygons_vertices: Array
var _last_biases: Array
var _last_test: bool


func _ready():
	build()


func _process(_delta):
	if _should_draw():
		queue_redraw()


func _draw():
	if not Engine.is_editor_hint():
		return
	
	build()
	
	for i in polygons.size():
		var polygon := polygons[i] as Polygon
		_draw_polygon(polygon, i)
	
	if test:
		_test()


func build():
	polygons.clear()
	
	for i in polygons_vertices.size():
		var polygon_vertices := polygons_vertices[i] as PackedVector2Array
		
		var polygon := Polygon.new(polygon_vertices)
		polygon.index = i # Ugly
		polygons.push_back(polygon)


func random_point(rng: RandomNumberGenerator = null) -> PointSampler2DResult:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	
	var polygon := Shape.random_by_area(rng, polygons, biases) as Polygon
	var position := polygon.random_point(rng)
	
	return PointSampler2DResult.new(position, polygon.index)


func _test():
	for i in 5000:
		var result := random_point()
		draw_circle(result.position, 1, Color.WHITE)


func _should_draw() -> bool:
	if not Engine.is_editor_hint():
		return false
	
	if polygons_vertices == _last_polygons_vertices and biases == _last_biases and test == _last_test:
		return false
	
	_last_polygons_vertices = polygons_vertices
	_last_biases = biases
	_last_test = test
	
	if polygons_vertices == null or polygons_vertices.is_empty():
		return false
	
	for polygon_vertices in polygons_vertices:
		if polygon_vertices == null or polygon_vertices.is_empty():
			return false
		
		if polygon_vertices.size() < 3:
			return false
	
	return true


func _draw_polygon(polygon: Polygon, index: int):
	polygon.paint(index)
	
	for triangle in polygon.triangles:
		_draw_triangle(triangle)
	
	draw_polyline(polygon.segments, polygon.color.blend(Color.WHITE), 1.0)
	
	if biases.is_empty():
		return
	
	var center := Vector2.ZERO
	
	for vertex in polygon.vertices:
		center += vertex
	
	center /= polygon.vertices.size()

	# If using this method in a script that redraws constantly, move the
	# `default_font` declaration to a member variable assigned in `_ready()`
	# so the Control is only created once.
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	
	draw_string(
		default_font,
		center,
		str(polygon.index),
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		default_font_size
	)


func _draw_triangle(triangle: Triangle):
	var vertices := [triangle.a(), triangle.b(), triangle.c()]
	var segments := Shape.segments_from_vertices(vertices)
	draw_colored_polygon(segments, triangle.color)
	draw_polyline(segments, Color.WHITE)


class Shape:
	var area: float
	
	# Editor
	var color: Color
	
	static func segments_from_vertices(vertices: PackedVector2Array) -> PackedVector2Array:
		var vertices_offset := vertices.slice(1)
		vertices_offset.push_back(vertices[0])
		
		var segments := PackedVector2Array()
		
		for i in vertices.size():
			segments.push_back(vertices[i])
			segments.push_back(vertices_offset[i])
		
		return segments
	
	static func random_by_area(rng: RandomNumberGenerator, shapes: Array, biases: Array = []) -> Shape:
		var bias := func(i: int) -> float:
			if biases.is_empty(): return 1.0
			return biases[i]
		
		var area_total := 0.0
			
		for i in shapes.size():
			area_total += shapes[i].area * bias.call(i)
		
		var epsilon = 1e-15
		var random_n := rng.randf_range(0, area_total - epsilon)
		
		for i in shapes.size():
			var shape := shapes[i] as Shape
			var contribution = shape.area * bias.call(i)
			
			if random_n < contribution:
				return shape
			
			random_n -= contribution
		
		return null # Should never happen


class Triangle extends Shape:
	var segments: PackedVector2Array
	var vertex_a: int
	var vertex_b: int
	var vertex_c: int
	
	func _init(segments: PackedVector2Array, a: int, b: int, c: int):
		self.segments = segments
		self.vertex_a = a
		self.vertex_b = b
		self.vertex_c = c
		self.area = _calculate_area()
	
	func a() -> Vector2:
		return segments[vertex_a]
	
	func b() -> Vector2:
		return segments[vertex_b]
	
	func c() -> Vector2:
		return segments[vertex_c]
	
	func _calculate_area() -> float:
		var a := a()
		var b := b()
		var c := c()
		
		var ab := b - a
		var ac := c - a
		
		var parallelogram_area := absf(ab.cross(ac))
		return parallelogram_area / 2.0
	
	func random_point(rng: RandomNumberGenerator):
		var a := a()
		var b := b()
		var c := c()
		
		var r1 := rng.randf()
		var r2 := rng.randf()
		
		return a + sqrt(r1) * (-a + b + r2 * (c - b))
	
	# Editor
	func paint(polygon_color: Color):
		var variation := 6
		
		var hash_a := [a()].hash() % variation
		var hash_b := [b()].hash() % variation
		var hash_c := [c()].hash() % variation
		
		var step := 0.03
		
		var offsets := [
			-(step * variation / 2) + (step * hash_a),
			-(step * variation / 2) + (step * hash_b),
			-(step * variation / 2) + (step * hash_c),
		]
		
		color = Color(
			polygon_color.r + offsets[0],
			polygon_color.g + offsets[1],
			polygon_color.b + offsets[2],
			polygon_color.a
		)


class Polygon extends Shape:
	var vertices: PackedVector2Array
	var segments: PackedVector2Array
	var triangles: Array# of Triangle
	var weight: float
	
	var index: int # Ugly
	
	func _init(vertices: PackedVector2Array, weight: float = 1.0):
		self.vertices = vertices
		self.weight = weight
		self.segments = Shape.segments_from_vertices(vertices)
		
		var triangle_vertices := Geometry2D.triangulate_delaunay(segments)
		
		for i in triangle_vertices.size() / 3:
			var triangle_idx := i * 3
			
			var triangle := Triangle.new(
				segments,
				triangle_vertices[triangle_idx + 0],
				triangle_vertices[triangle_idx + 1],
				triangle_vertices[triangle_idx + 2],
			)
			
			triangles.push_back(triangle)
			self.area += triangle.area
	
	func random_triangle(rng: RandomNumberGenerator) -> Triangle:
		return random_by_area(rng, triangles)
	
	func random_point(rng: RandomNumberGenerator) -> Vector2:
		var triangle := random_triangle(rng)
		return triangle.random_point(rng)
	
	# Editor
	func paint(index: int):
		var palette := [
			Color.hex(0xfff07c66),
			Color.hex(0xeec0c666),
			Color.hex(0x80ff7266),
			Color.hex(0xf7a07266),
			Color.hex(0x7ee8fa66),
		]
		
		var effective_index := index % palette.size()
		color = palette[effective_index]
		
		for triangle in triangles:
			triangle.paint(color)


class PointSampler2DResult:
	var position: Vector2
	var polygon: int
	
	func _init(position: Vector2, polygon: int):
		self.position = position
		self.polygon = polygon
