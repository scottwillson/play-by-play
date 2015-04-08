(ns play-by-play.strings-test
  (:require [play-by-play.strings :refer :all]
            [clojure.test :refer :all]))

(deftest test-to-camel-case
  (testing "empty string"
    (is (= "" (to-camel-case ""))))

  (testing "single word"
    (is (= "key" (to-camel-case "key"))))

  (testing "dashed word"
    (is (= "dashKey" (to-camel-case "dash-key")))))
