(ns play-by-play.player-test
  (:require [clojure.test :refer :all]
            [play-by-play.player :refer :all]))

(deftest test-create
  (testing "name length"
   (is
     (> (count
       (:name (create))) 3)))

   (testing "points"
     (is
       (= (:points (create))) 0)))

(deftest test-plays-for
  (testing "no plays"
    (let [game  {:plays []}
          plays (plays-for "Rondo" game)]
    (is (= [] plays))))

  (testing "plays for different players"
    (let [game  {:plays [{:player "Lopez"}
                         {:player "Rondo"}
                         {:player "Lopez"}]}]
    (is (= 1 (count (plays-for {:name "Rondo"} game))))
    (is (= 2 (count (plays-for {:name "Lopez"} game))))))

  ; Edge case that will be fixed by player IDs
  (testing "plays for different players same name different team"
    (let [game  {:plays [{:player "Lopez" :team "Bulls"}
                         {:player "Rondo" :team "Bulls"}
                         {:player "Rondo" :team "Cavs"}
                         {:player "Lopez" :team "Bulls"}]}]
    (is (= 1 (count (plays-for {:name "Rondo" :team "Bulls"} game))))
    (is (= 1 (count (plays-for {:name "Rondo" :team "Cavs"} game))))
    (is (= 2 (count (plays-for {:name "Lopez" :team "Bulls"} game))))
    (is (= 0 (count (plays-for {:name "Lopez" :team "Cavs"} game)))))))

(deftest test-sum-points
  (testing "no plays"
    (let [game  {:plays []
                 :teams [{:name "Cleveland" :players {:name "Rondo"}} {:name "Washington" :players {:name "Wall"}}]}]
    (is (= {:name "Rondo" :points 0} (sum-points {:name "Rondo"} game)))
    (is (= {:name "Wall" :points 0} (sum-points {:name "Wall"} game)))))

  (testing "plays for different players"
    (let [game  {:plays [{:player "Lopez", :points 2}
                         {:player "Rondo", :points 3}
                         {:player "Lopez", :points 2}]
                 :teams [{:name "Cleveland" :players {:name "Rondo"}} {:name "Washington" :players {:name "Lopez"}}]}]
    (is (= {:name "Lopez" :points 4} (sum-points {:name "Lopez"} game)))
    (is (= {:name "Rondo" :points 3} (sum-points {:name "Rondo"} game)))
    (is (= {:name "Wall" :points 0} (sum-points {:name "Wall"} game))))))

(deftest test-points-for
  (testing "no plays"
    (let [game  {:plays []
                 :teams [{:name "Cleveland" :players {:name "Rondo"}} {:name "Washington" :players {:name "Wall"}}]}]
    (is (= 0 (points-for "Rondo" game)))))

  (testing "plays for different players"
    (let [game  {:plays [{:player "Lopez", :points 2}
                         {:player "Rondo", :points 3}
                         {:player "Lopez", :points 2}]}]
    (is (= 3 (points-for {:name "Rondo"} game)))
    (is (= 4 (points-for {:name "Lopez"} game))))))
