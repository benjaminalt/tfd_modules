(define (domain tidyup-putdown)
    (:requirements :strips :typing :durative-actions :fluents :derived-predicates :equality)

    (:types 
        pose                            ; any pose in space
        frameid                         ; the coordinate frame of a pose, ideally a fixed frame
        
        location - pose                 ; a pose for the robot base
        grasp_location - location       ; a location that grasp actions can be applied from
                                        ; (e.g. a location at a table)

        static_object                   ; something static like a table
        movable_object                  ; an object that could be grasped
        object_pose - pose              ; pose for an object, 
                                        ; can be the pose of an object or where an object can be put

        arm                             ; use left or right arm, see constants
        arm_position                    ; specific arm positions, see constants
    )

    (:constants
       left_arm right_arm - arm
       tucked untucked post-grasped - arm_position
    )

    (:predicates
        (at-base ?l - location)                           ; location of the base
        (can-navigate ?s - location ?g - location)        ; is there a path from ?s to ?g

        (searched ?l - grasp_location)            ; did we perform detect-objects at this location at some time?
        (recent-detected-objects ?l - grasp_location)     ; did we perform detect-objects at this location, without something changing (like driving in between)

        ; Both set from object detection
        (graspable-from ?o - movable_object ?g - grasp_location ?a - arm)  ; is ?o graspable from ?g with ?a
        (can-putdown ?o - movable_object ?p - object_pose ?a - arm ?g - grasp_location)
        ; can we putdown ?o held in ?a at ?p when base is at ?g

        ; TODO how to get this
        (belongs-to ?p - object_pose ?s - static_object)    ; is ?p a pose located at/in ?s

        (handFree ?a - arm)                           ; nothing grasped in arm ?a
        (grasped ?o - movable_object ?a - arm)        ; grasped ?o with arm ?a

        (tidy-location ?o ?s)                       ; if ?o is on ?s it is considered tidied up
    )

    (:functions
        (x ?p - pose) - number
        (y ?p - pose) - number
        (z ?p - pose) - number
        ; quaternion orientation
        (qx ?p - pose) - number
        (qy ?p - pose) - number
        (qz ?p - pose) - number
        (qw ?p - pose) - number
        (timestamp ?p - pose) - number      ; unix time in s
        (frame-id ?p - pose) - frameid
        (at-object ?o - movable_object) - object_pose

        (arm-position ?a - arm) - arm_position
    )

    ; while at ?l grasp ?o from ?s using ?a
    (:durative-action grasp
	    :parameters (?l - grasp_location ?o - movable_object ?s - static_object ?a - arm)
        :duration (= ?duration 1.0)
	    :condition (and
            ; HACK grasp only works with r_arm
            (at start (= ?a right_arm))
            (at start (at-base ?l))
            (at start (on ?o ?s))
            (at start (handFree ?a))
            (at start (graspable-from ?o ?l ?a))
            (at start (not (= (arm-position ?a) tucked)))
            (at start (recent-detected-objects ?l))
            )
	    :effect
	    (and 
            (at end (not (handFree ?a)))
            (at end (grasped ?o ?a))
            (at end (assign (at-object ?o) undefined))
            (at start (assign (arm-position ?a) undefined))
            (at end (not (graspable-from ?o ?l ?a)))
            (forall (?l - location) (at start (not (recent-detected-objects ?l))))  ; we possibly changed graspable or can-putdown
            ; TODO if there are untidy objects here, mark it not searched (might become graspable when looking again)
        )
    )

    ; place ?o in ?a at pose ?p (while robot is at ?l)
    (:durative-action place
	    :parameters (?l - grasp_location ?o - movable_object ?p - object_pose ?a - arm)
        :duration (= ?duration 1.0)
	    :condition (and
            ; HACK grasp only works with r_arm
            (at start (= ?a right_arm))
            (at start (at-base ?l))
            (at start (grasped ?o ?a))
            (at start (can-putdown ?o ?p ?a ?l))
            (at start (recent-detected-objects ?l))
            )
	    :effect
	    (and 
            (at end (handFree ?a))
            (at end (not (grasped ?o ?a)))
            (at end (assign (at-object ?o) ?p))
            (at start (assign (arm-position ?a) undefined))
            (forall (?l - location) (at start (not (recent-detected-objects ?l))))  ; we possibly changed graspable or can-putdown
        )
    )

    (:durative-action detect-objects
        :parameters (?l - grasp_location)
        :duration (= ?duration 1.0)
        :condition
            (and
                (at start (at-base ?l))
                (at start 
                    (or
                        (not (searched ?l))
                        (not (recent-detected-objects ?l))
                    )
                )
                (at start (forall (?a - arm) (= (arm-position ?a) untucked)))
            )
        :effect (and
            (at end (searched ?l))
            (at end (recent-detected-objects ?l))
            )
    )

    (:durative-action drive-base
	    :parameters (?s - location ?g - location)
        :duration (= ?duration 1.0)
	    :condition (and
            (at start (at-base ?s))
            (at start (not (= ?s ?g)))
            (at start (or (can-navigate ?s ?g) (can-navigate ?g ?s)))
            ; make sure arms are in drive position
            ; no object holding arms should be tucked
            (at start
                (forall (?a - arm)
                    (imply (handFree ?a) (= (arm-position ?a) tucked))))
            ; arms holding an object should be in post-grasped
            (at start
                (forall (?a - arm)
                    (imply (not (handFree ?a)) (= (arm-position ?a) post-grasped))))
            )
	    :effect
	    (and 
            (at start (not (at-base ?s)))
            (at end (at-base ?g))
            (forall (?l - location) (at start (not (recent-detected-objects ?l))))
        )
    )

    ;; maybe shouldnt be tucked
    (:durative-action move-to-post-grasp
        :parameters (?a - arm)
        :duration (= ?duration 1.0)
        :condition (and
            (at start (not (= (arm-position ?a) post-grasped)))
            )
        :effect (and
            (change (arm-position ?a) post-grasped)
            )
    )

    ; unfortunately it is not possible to only tuck/untuck one arm, which is why this uglieness happens
    (:durative-action untuck-arms
        :parameters (?l - arm ?r - arm)
        :duration (= ?duration 1.0)
        :condition (and
            (at start (= ?l left_arm))
            (at start (= ?r right_arm))
            (at start
                (or
                    (not (= (arm-position ?l) untucked))
                    (not (= (arm-position ?r) untucked))
                )
            ))
        :effect (and
            (change (arm-position ?l) untucked)
            (change (arm-position ?r) untucked)
            )
    )
    (:durative-action tuck-arms
        :parameters (?l - arm ?r - arm)
        :duration (= ?duration 1.0)
        :condition 
            (and
                (at start (= ?l left_arm))
                (at start (= ?r right_arm))
                (at start (handFree ?l))
                (at start (handFree ?r))
                (at start
                    (or
                        (not (= (arm-position ?l) tucked))
                        (not (= (arm-position ?r) tucked))
                    )
                )
            )
        :effect (and
            (change (arm-position ?l) tucked)
            (change (arm-position ?r) tucked)
            )
    )
    (:durative-action tuck-left-untuck-right
        :parameters (?l - arm ?r - arm)
        :duration (= ?duration 1.0)
        :condition 
            (and
                (at start (= ?l left_arm))
                (at start (= ?r right_arm))
                (at start (handFree ?l))
                (at start
                    (or
                        (not (= (arm-position ?l) tucked))
                        (not (= (arm-position ?r) untucked))
                ))
            )
        :effect (and
            (change (arm-position ?l) tucked)
            (change (arm-position ?r) untucked)
            )
    )
    (:durative-action untuck-left-tuck-right
        :parameters (?l - arm ?r - arm)
        :duration (= ?duration 1.0)
        :condition 
            (and
                (at start (= ?l left_arm))
                (at start (= ?r right_arm))
                (at start (handFree ?r))
                (at start
                    (or
                        (not (= (arm-position ?l) untucked))
                        (not (= (arm-position ?r) tucked))
                    )
                )
            )
        :effect (and
            (change (arm-position ?l) untucked)
            (change (arm-position ?r) tucked)
            )
    )


    ; A movable_object ?o is on a static_object ?s iff
    ; there is some object_pose ?p that belongs to ?s and ?o is at ?p
    (:derived
        (on ?o - movable_object ?s - static_object)
        (exists (?p - object_pose)
            (and (belongs-to ?p ?s) (= (at-object ?o) ?p)))
    )

    (:derived
        (tidy ?o - movable_object)
        ; if there is a tidy-location and the object is somehow graspable, it should be there
        (imply
            (and
                (exists (?s - static_object) (tidy-location ?o ?s))     ; tidy-location defined (needs to be tidied)
                ; The object can actually somehow be grasped
                (or
                    ; Either becasue is is graspable from a location
                    (exists (?a - arm)                                      ; there is some arm and
                        (exists (?l - grasp_location)                       ; some location so that
                            (graspable-from ?o ?l ?a)))                     ; we can somehow grasp the object
                    ; Or because some other object on the same location is graspable 
                    ; (and thus could be moved out of the way to get to ?o)
                    (exists (?other - movable_object)
                        (exists (?s - static_object)        ; there is another object
                            (and (on ?other ?s) (on ?o ?s)  ; that is on the same ?s as ?o
                                ; and we can somehow grasp ?other
                                (exists (?a - arm) (exists (?l - grasp_location) (graspable-from ?other ?l ? a)))
                            )
                        )
                    )
                )
            )   ; THEN
            ; there is some static_object that is a tidy-location for ?o and ?o is actually there (i.e. ?o is tidy)
            (exists (?s - static_object) (and (tidy-location ?o ?s) (on ?o ?s)))
        )
    )
)

