' Segment Operations Example - QB64 Basic
' Demonstrates marking, selecting, and manipulating segments

'$INCLUDE: 'line_segment_tracer.bas'

PROGRAM Example_SegmentOperations

DIM stats AS Statistics
DIM i AS LONG

' Initialize the tracer
CALL InitializeTracer

PRINT "=== Segment Operations Example ==="
PRINT

' Create a simple polyline with 5 segments
FOR i = 0 TO 4
    CALL AddSegment(i, 0, i + 1, 0.5)
NEXT i

PRINT "Created 5 line segments"
PRINT

CALL PrintAllSegments

' Perform various operations
PRINT "=== Performing segment operations ==="
PRINT

' Select segments 1, 3, 5
CALL SelectSegment(1)
CALL SelectSegment(3)
CALL SelectSegment(5)

PRINT "Selected segments: 1, 3, 5"
CALL PrintAllSegments
PRINT

' Mark segment 2 as bad
CALL MarkSegmentBad(2)
PRINT "Marked segment 2 as bad"
CALL PrintAllSegments
PRINT

' Deselect segment 3
CALL DeselectSegment(3)
PRINT "Deselected segment 3"
CALL PrintAllSegments
PRINT

' Assign segments to rings
CALL AssignSegmentToRing(1, 10)
CALL AssignSegmentToRing(2, 10)
CALL AssignSegmentToRing(3, 20)
CALL AssignSegmentToRing(4, 20)
CALL AssignSegmentToRing(5, 30)

PRINT "Assigned to rings:"
PRINT "  Segments 1,2 -> Ring 10"
PRINT "  Segments 3,4 -> Ring 20"
PRINT "  Segment 5 -> Ring 30"
CALL PrintAllSegments
PRINT

' Assign to pockets
CALL AssignSegmentToPocket(1, 100)
CALL AssignSegmentToPocket(2, 100)
CALL AssignSegmentToPocket(3, 200)
CALL AssignSegmentToPocket(4, 200)
CALL AssignSegmentToPocket(5, 300)

PRINT "Assigned to pockets:"
PRINT "  Segments 1,2 -> Pocket 100"
PRINT "  Segments 3,4 -> Pocket 200"
PRINT "  Segment 5 -> Pocket 300"
CALL PrintAllSegments
PRINT

' Trim segments
CALL TrimSegment(1, 0, 0.5)
CALL TrimSegment(3, 0.25, 0.75)
CALL TrimSegment(5, 0.1, 0.9)

PRINT "Applied trims to segments 1, 3, 5"
CALL PrintAllSegments
PRINT

' Print final statistics
CALL CalculateStatistics(stats)

PRINT "=== Final Statistics ==="
PRINT "Total Segments: "; stats.totalSegments
PRINT "Active Segments: "; stats.activeSegments
PRINT "Selected Segments: "; stats.selectedSegments
PRINT "Total Length: "; stats.totalLength
PRINT "Total Junctions: "; stats.totalJunctions
PRINT

' Demonstrate deactivation
PRINT "Deactivating segment 2..."
CALL DeactivateSegment(2)

CALL PrintStatistics

END PROGRAM
