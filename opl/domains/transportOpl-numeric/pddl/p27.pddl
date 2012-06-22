; Transport p21-30-city-hubs-6hubs-4htrucks-4citysize-1ctrucks-14packages-2008

(define (problem transport-p21-30-city-hubs-6hubs-4htrucks-4citysize-1ctrucks-14packages-2008)
 (:domain transport)
 (:objects
  hub-0 - Location
  hub-1 - Location
  hub-2 - Location
  hub-3 - Location
  hub-4 - Location
  hub-5 - Location
  v0 - Vehicle
  v1 - Vehicle
  v2 - Vehicle
  v3 - Vehicle
  ctruck-0-0 - Vehicle
  ctruck-1-0 - Vehicle
  ctruck-2-0 - Vehicle
  ctruck-3-0 - Vehicle
  ctruck-4-0 - Vehicle
  ctruck-5-0 - Vehicle
  city-0-0 - Location
  city-0-1 - Location
  city-0-2 - Location
  city-0-3 - Location
  city-1-0 - Location
  city-1-1 - Location
  city-1-2 - Location
  city-1-3 - Location
  city-2-0 - Location
  city-2-1 - Location
  city-2-2 - Location
  city-2-3 - Location
  city-3-0 - Location
  city-3-1 - Location
  city-3-2 - Location
  city-3-3 - Location
  city-4-0 - Location
  city-4-1 - Location
  city-4-2 - Location
  city-4-3 - Location
  city-5-0 - Location
  city-5-1 - Location
  city-5-2 - Location
  city-5-3 - Location
  p0 - Package
  p1 - Package
  p2 - Package
  p3 - Package
  p4 - Package
  p5 - Package
  p6 - Package
  p7 - Package
  p8 - Package
  p9 - Package
  p10 - Package
  p11 - Package
  p12 - Package
  p13 - Package
 )
 (:init
  (road hub-0 hub-1)
  (= (roadLength hub-0 hub-1) 20)
  (= (fuelDemand hub-0 hub-1) 15)
  (road hub-1 hub-0)
  (= (roadLength hub-1 hub-0) 20)
  (= (fuelDemand hub-1 hub-0) 15)
  (road hub-1 hub-2)
  (= (roadLength hub-1 hub-2) 20)
  (= (fuelDemand hub-1 hub-2) 14)
  (road hub-2 hub-1)
  (= (roadLength hub-2 hub-1) 25)
  (= (fuelDemand hub-2 hub-1) 16)
  (road hub-2 hub-3)
  (= (roadLength hub-2 hub-3) 20)
  (= (fuelDemand hub-2 hub-3) 15)
  (road hub-3 hub-2)
  (= (roadLength hub-3 hub-2) 20)
  (= (fuelDemand hub-3 hub-2) 15)
  (road hub-3 hub-4)
  (= (roadLength hub-3 hub-4) 20)
  (= (fuelDemand hub-3 hub-4) 14)
  (road hub-4 hub-3)
  (= (roadLength hub-4 hub-3) 25)
  (= (fuelDemand hub-4 hub-3) 16)
  (road hub-4 hub-5)
  (= (roadLength hub-4 hub-5) 20)
  (= (fuelDemand hub-4 hub-5) 15)
  (road hub-5 hub-4)
  (= (roadLength hub-5 hub-4) 20)
  (= (fuelDemand hub-5 hub-4) 15)
  (road hub-5 hub-0)
  (= (roadLength hub-5 hub-0) 20)
  (= (fuelDemand hub-5 hub-0) 14)
  (road hub-0 hub-5)
  (= (roadLength hub-0 hub-5) 25)
  (= (fuelDemand hub-0 hub-5) 16)
  (road city-0-0 city-0-1)
  (= (roadLength city-0-0 city-0-1) 10)
  (= (fuelDemand city-0-0 city-0-1) 12)
  (road city-0-1 city-0-0)
  (= (roadLength city-0-1 city-0-0) 10)
  (= (fuelDemand city-0-1 city-0-0) 12)
  (road city-0-1 city-0-2)
  (= (roadLength city-0-1 city-0-2) 10)
  (= (fuelDemand city-0-1 city-0-2) 12)
  (road city-0-2 city-0-1)
  (= (roadLength city-0-2 city-0-1) 10)
  (= (fuelDemand city-0-2 city-0-1) 12)
  (road city-0-2 city-0-3)
  (= (roadLength city-0-2 city-0-3) 10)
  (= (fuelDemand city-0-2 city-0-3) 12)
  (road city-0-3 city-0-2)
  (= (roadLength city-0-3 city-0-2) 10)
  (= (fuelDemand city-0-3 city-0-2) 12)
  (road city-0-2 city-0-0)
  (= (roadLength city-0-2 city-0-0) 10)
  (= (fuelDemand city-0-2 city-0-0) 12)
  (road city-0-0 city-0-2)
  (= (roadLength city-0-0 city-0-2) 10)
  (= (fuelDemand city-0-0 city-0-2) 12)
  (road city-0-0 hub-0)
  (= (roadLength city-0-0 hub-0) 3)
  (= (fuelDemand city-0-0 hub-0) 2)
  (road hub-0 city-0-0)
  (= (roadLength hub-0 city-0-0) 3)
  (= (fuelDemand hub-0 city-0-0) 2)
  (road city-1-0 city-1-1)
  (= (roadLength city-1-0 city-1-1) 10)
  (= (fuelDemand city-1-0 city-1-1) 12)
  (road city-1-1 city-1-0)
  (= (roadLength city-1-1 city-1-0) 10)
  (= (fuelDemand city-1-1 city-1-0) 12)
  (road city-1-1 city-1-2)
  (= (roadLength city-1-1 city-1-2) 10)
  (= (fuelDemand city-1-1 city-1-2) 12)
  (road city-1-2 city-1-1)
  (= (roadLength city-1-2 city-1-1) 10)
  (= (fuelDemand city-1-2 city-1-1) 12)
  (road city-1-3 city-1-0)
  (= (roadLength city-1-3 city-1-0) 10)
  (= (fuelDemand city-1-3 city-1-0) 12)
  (road city-1-0 city-1-3)
  (= (roadLength city-1-0 city-1-3) 10)
  (= (fuelDemand city-1-0 city-1-3) 12)
  (road city-1-1 city-1-3)
  (= (roadLength city-1-1 city-1-3) 10)
  (= (fuelDemand city-1-1 city-1-3) 12)
  (road city-1-3 city-1-1)
  (= (roadLength city-1-3 city-1-1) 10)
  (= (fuelDemand city-1-3 city-1-1) 12)
  (road city-1-3 hub-1)
  (= (roadLength city-1-3 hub-1) 3)
  (= (fuelDemand city-1-3 hub-1) 2)
  (road hub-1 city-1-3)
  (= (roadLength hub-1 city-1-3) 3)
  (= (fuelDemand hub-1 city-1-3) 2)
  (road city-2-0 city-2-1)
  (= (roadLength city-2-0 city-2-1) 10)
  (= (fuelDemand city-2-0 city-2-1) 12)
  (road city-2-1 city-2-0)
  (= (roadLength city-2-1 city-2-0) 10)
  (= (fuelDemand city-2-1 city-2-0) 12)
  (road city-2-1 city-2-2)
  (= (roadLength city-2-1 city-2-2) 10)
  (= (fuelDemand city-2-1 city-2-2) 12)
  (road city-2-2 city-2-1)
  (= (roadLength city-2-2 city-2-1) 10)
  (= (fuelDemand city-2-2 city-2-1) 12)
  (road city-2-2 city-2-3)
  (= (roadLength city-2-2 city-2-3) 10)
  (= (fuelDemand city-2-2 city-2-3) 12)
  (road city-2-3 city-2-2)
  (= (roadLength city-2-3 city-2-2) 10)
  (= (fuelDemand city-2-3 city-2-2) 12)
  (road city-2-3 city-2-1)
  (= (roadLength city-2-3 city-2-1) 10)
  (= (fuelDemand city-2-3 city-2-1) 12)
  (road city-2-1 city-2-3)
  (= (roadLength city-2-1 city-2-3) 10)
  (= (fuelDemand city-2-1 city-2-3) 12)
  (road city-2-0 hub-2)
  (= (roadLength city-2-0 hub-2) 3)
  (= (fuelDemand city-2-0 hub-2) 2)
  (road hub-2 city-2-0)
  (= (roadLength hub-2 city-2-0) 3)
  (= (fuelDemand hub-2 city-2-0) 2)
  (road city-3-0 city-3-1)
  (= (roadLength city-3-0 city-3-1) 10)
  (= (fuelDemand city-3-0 city-3-1) 12)
  (road city-3-1 city-3-0)
  (= (roadLength city-3-1 city-3-0) 10)
  (= (fuelDemand city-3-1 city-3-0) 12)
  (road city-3-1 city-3-2)
  (= (roadLength city-3-1 city-3-2) 10)
  (= (fuelDemand city-3-1 city-3-2) 12)
  (road city-3-2 city-3-1)
  (= (roadLength city-3-2 city-3-1) 10)
  (= (fuelDemand city-3-2 city-3-1) 12)
  (road city-3-3 city-3-0)
  (= (roadLength city-3-3 city-3-0) 10)
  (= (fuelDemand city-3-3 city-3-0) 12)
  (road city-3-0 city-3-3)
  (= (roadLength city-3-0 city-3-3) 10)
  (= (fuelDemand city-3-0 city-3-3) 12)
  (road city-3-2 city-3-0)
  (= (roadLength city-3-2 city-3-0) 10)
  (= (fuelDemand city-3-2 city-3-0) 12)
  (road city-3-0 city-3-2)
  (= (roadLength city-3-0 city-3-2) 10)
  (= (fuelDemand city-3-0 city-3-2) 12)
  (road city-3-3 hub-3)
  (= (roadLength city-3-3 hub-3) 3)
  (= (fuelDemand city-3-3 hub-3) 2)
  (road hub-3 city-3-3)
  (= (roadLength hub-3 city-3-3) 3)
  (= (fuelDemand hub-3 city-3-3) 2)
  (road city-4-0 city-4-1)
  (= (roadLength city-4-0 city-4-1) 10)
  (= (fuelDemand city-4-0 city-4-1) 12)
  (road city-4-1 city-4-0)
  (= (roadLength city-4-1 city-4-0) 10)
  (= (fuelDemand city-4-1 city-4-0) 12)
  (road city-4-2 city-4-3)
  (= (roadLength city-4-2 city-4-3) 10)
  (= (fuelDemand city-4-2 city-4-3) 12)
  (road city-4-3 city-4-2)
  (= (roadLength city-4-3 city-4-2) 10)
  (= (fuelDemand city-4-3 city-4-2) 12)
  (road city-4-3 city-4-0)
  (= (roadLength city-4-3 city-4-0) 10)
  (= (fuelDemand city-4-3 city-4-0) 12)
  (road city-4-0 city-4-3)
  (= (roadLength city-4-0 city-4-3) 10)
  (= (fuelDemand city-4-0 city-4-3) 12)
  (road city-4-1 city-4-3)
  (= (roadLength city-4-1 city-4-3) 10)
  (= (fuelDemand city-4-1 city-4-3) 12)
  (road city-4-3 city-4-1)
  (= (roadLength city-4-3 city-4-1) 10)
  (= (fuelDemand city-4-3 city-4-1) 12)
  (road city-4-2 hub-4)
  (= (roadLength city-4-2 hub-4) 3)
  (= (fuelDemand city-4-2 hub-4) 2)
  (road hub-4 city-4-2)
  (= (roadLength hub-4 city-4-2) 3)
  (= (fuelDemand hub-4 city-4-2) 2)
  (road city-5-0 city-5-1)
  (= (roadLength city-5-0 city-5-1) 10)
  (= (fuelDemand city-5-0 city-5-1) 12)
  (road city-5-1 city-5-0)
  (= (roadLength city-5-1 city-5-0) 10)
  (= (fuelDemand city-5-1 city-5-0) 12)
  (road city-5-1 city-5-2)
  (= (roadLength city-5-1 city-5-2) 10)
  (= (fuelDemand city-5-1 city-5-2) 12)
  (road city-5-2 city-5-1)
  (= (roadLength city-5-2 city-5-1) 10)
  (= (fuelDemand city-5-2 city-5-1) 12)
  (road city-5-3 city-5-0)
  (= (roadLength city-5-3 city-5-0) 10)
  (= (fuelDemand city-5-3 city-5-0) 12)
  (road city-5-0 city-5-3)
  (= (roadLength city-5-0 city-5-3) 10)
  (= (fuelDemand city-5-0 city-5-3) 12)
  (road city-5-2 city-5-0)
  (= (roadLength city-5-2 city-5-0) 10)
  (= (fuelDemand city-5-2 city-5-0) 12)
  (road city-5-0 city-5-2)
  (= (roadLength city-5-0 city-5-2) 10)
  (= (fuelDemand city-5-0 city-5-2) 12)
  (road city-5-2 hub-5)
  (= (roadLength city-5-2 hub-5) 3)
  (= (fuelDemand city-5-2 hub-5) 2)
  (road hub-5 city-5-2)
  (= (roadLength hub-5 city-5-2) 3)
  (= (fuelDemand hub-5 city-5-2) 2)
  (Location_hasPetrolStation hub-0)
  (Location_hasPetrolStation hub-1)
  (Location_hasPetrolStation hub-2)
  (Location_hasPetrolStation hub-3)
  (Location_hasPetrolStation hub-4)
  (Location_hasPetrolStation hub-5)
  (Vehicle_readyLoading v0)
  (= (Vehicle_capacity v0) 100)
  (= (Vehicle_fuelLeft v0) 0)
  (= (Vehicle_fuelMax v0) 90)
  (Locatable_at v0 hub-0)
  (Vehicle_readyLoading v1)
  (= (Vehicle_capacity v1) 100)
  (= (Vehicle_fuelLeft v1) 0)
  (= (Vehicle_fuelMax v1) 90)
  (Locatable_at v1 hub-1)
  (Vehicle_readyLoading v2)
  (= (Vehicle_capacity v2) 100)
  (= (Vehicle_fuelLeft v2) 0)
  (= (Vehicle_fuelMax v2) 90)
  (Locatable_at v2 hub-2)
  (Vehicle_readyLoading v3)
  (= (Vehicle_capacity v3) 100)
  (= (Vehicle_fuelLeft v3) 0)
  (= (Vehicle_fuelMax v3) 90)
  (Locatable_at v3 hub-3)
  (Vehicle_readyLoading ctruck-0-0)
  (= (Vehicle_capacity ctruck-0-0) 30)
  (= (Vehicle_fuelLeft ctruck-0-0) 0)
  (= (Vehicle_fuelMax ctruck-0-0) 76)
  (Locatable_at ctruck-0-0 hub-0)
  (Vehicle_readyLoading ctruck-1-0)
  (= (Vehicle_capacity ctruck-1-0) 30)
  (= (Vehicle_fuelLeft ctruck-1-0) 0)
  (= (Vehicle_fuelMax ctruck-1-0) 76)
  (Locatable_at ctruck-1-0 hub-1)
  (Vehicle_readyLoading ctruck-2-0)
  (= (Vehicle_capacity ctruck-2-0) 30)
  (= (Vehicle_fuelLeft ctruck-2-0) 0)
  (= (Vehicle_fuelMax ctruck-2-0) 76)
  (Locatable_at ctruck-2-0 hub-2)
  (Vehicle_readyLoading ctruck-3-0)
  (= (Vehicle_capacity ctruck-3-0) 30)
  (= (Vehicle_fuelLeft ctruck-3-0) 0)
  (= (Vehicle_fuelMax ctruck-3-0) 76)
  (Locatable_at ctruck-3-0 hub-3)
  (Vehicle_readyLoading ctruck-4-0)
  (= (Vehicle_capacity ctruck-4-0) 30)
  (= (Vehicle_fuelLeft ctruck-4-0) 0)
  (= (Vehicle_fuelMax ctruck-4-0) 76)
  (Locatable_at ctruck-4-0 hub-4)
  (Vehicle_readyLoading ctruck-5-0)
  (= (Vehicle_capacity ctruck-5-0) 30)
  (= (Vehicle_fuelLeft ctruck-5-0) 0)
  (= (Vehicle_fuelMax ctruck-5-0) 76)
  (Locatable_at ctruck-5-0 hub-5)
  (= (Package_size p0) 10)
  (Locatable_at p0 city-0-2)
  (= (Package_size p1) 20)
  (Locatable_at p1 city-1-3)
  (= (Package_size p2) 10)
  (Locatable_at p2 city-2-0)
  (= (Package_size p3) 20)
  (Locatable_at p3 city-3-1)
  (= (Package_size p4) 10)
  (Locatable_at p4 city-4-2)
  (= (Package_size p5) 20)
  (Locatable_at p5 city-5-3)
  (= (Package_size p6) 10)
  (Locatable_at p6 city-0-0)
  (= (Package_size p7) 20)
  (Locatable_at p7 city-1-1)
  (= (Package_size p8) 10)
  (Locatable_at p8 city-2-2)
  (= (Package_size p9) 20)
  (Locatable_at p9 city-3-3)
  (= (Package_size p10) 10)
  (Locatable_at p10 city-4-0)
  (= (Package_size p11) 20)
  (Locatable_at p11 city-5-1)
  (= (Package_size p12) 10)
  (Locatable_at p12 city-0-2)
  (= (Package_size p13) 20)
  (Locatable_at p13 city-1-3)
 )
 (:goal (and
  (Locatable_at p0 city-3-2)
  (Locatable_at p1 city-4-1)
  (Locatable_at p2 city-5-0)
  (Locatable_at p3 city-0-3)
  (Locatable_at p4 city-1-2)
  (Locatable_at p5 city-2-1)
  (Locatable_at p6 city-3-0)
  (Locatable_at p7 city-4-3)
  (Locatable_at p8 city-5-2)
  (Locatable_at p9 city-0-1)
  (Locatable_at p10 city-1-0)
  (Locatable_at p11 city-2-3)
  (Locatable_at p12 city-3-2)
  (Locatable_at p13 city-4-1)
  (Locatable_at v0 hub-0)
  (Locatable_at v1 hub-1)
  (Locatable_at v2 hub-2)
  (Locatable_at v3 hub-3)
  (Locatable_at ctruck-0-0 hub-0)
  (Locatable_at ctruck-1-0 hub-1)
  (Locatable_at ctruck-2-0 hub-2)
  (Locatable_at ctruck-3-0 hub-3)
  (Locatable_at ctruck-4-0 hub-4)
  (Locatable_at ctruck-5-0 hub-5)
 ))
 (:metric minimize (total-time))
)
