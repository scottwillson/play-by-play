(ns play-by-play.real-world-test
  (:require [clojure.test :refer :all]
            [play-by-play.real-world :as rw]))

(deftest test-player
  (testing "name length"
    (is
      (> (count
        (:name (rw/player))) 3)))

    (testing "points"
      (is
        (>= (:points (rw/player))) 0)))
