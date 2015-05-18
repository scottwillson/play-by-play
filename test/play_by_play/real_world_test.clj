(ns play-by-play.real-world-test
  (:require [clojure.test :refer :all]
            [play-by-play.real-world :as rw]))

(deftest test-fgm
  (testing "count"
    (is (> (count (rw/fgm))) 100)))

(deftest test-headers
  (testing "headers"
    (is (= "GAME_ID" (first (rw/headers))))
    (is (= "PLAYER3_TEAM_ABBREVIATION" (last (rw/headers))))))
