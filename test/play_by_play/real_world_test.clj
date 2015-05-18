(ns play-by-play.real-world-test
  (:require [clojure.test :refer :all]
            [play-by-play.real-world :as rw]))

(deftest test-fgm
  (testing "count"
    (is (> (count (rw/fgm)) 70,000))))

(deftest test-three-pm
  (testing "count"
    (is (> (count (rw/three-pm)) 19,000))))

(deftest test-ftm
  (testing "count"
    (is (> (count (rw/ftm)) 500))))

(deftest test-headers
  (testing "headers"
    (is (= "GAME_ID" (first (rw/headers))))
    (is (= "PLAYER3_TEAM_ABBREVIATION" (last (rw/headers))))))
