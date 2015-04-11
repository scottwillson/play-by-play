(ns play-by-play.browser-test
  (:require [clojure.test :refer :all]
            [clj-webdriver.taxi :refer :all]
            [ring.adapter.jetty :as jetty :only [run-jetty]]
            [play-by-play.app-server.handler :as handler :only [app]]))

(deftest ^:browser home-page
  (testing "with date"
    ; 2012-2013 season opening day
    (to "http://0.0.0.0:3000/?date=2012-10-30")
    (is (and
      (exists? ".container")
      (= "Washington Wizards" (text ".game-score .visitor .team-name"))
      (re-find #"\d{2,3}" (text ".game-score .visitor .score"))
      (= "Cleveland Cavaliers" (text ".game-score .home .team-name"))
      (re-find #"\d{2,3}" (text ".game-score .home .score"))))))

(deftest ^:browser box-score
  (testing "view"
    (to "http://0.0.0.0:3000/box_score.html")
    (is (exists? ".container"))
    (is (= "Washington Wizards" (text "#box-score .visitor .team-name")))
    (is (re-find #"\d{2,3}" (text "#box-score .visitor .score")))
    (is (= "Cleveland Cavaliers" (text "#box-score .home .team-name")))
    (is (re-find #"\d{2,3}" (text "#box-score .home .score")))
    (is (= 30 (count (find-elements {:css ".player"}))))))

(defn ^:browser start-app-server [f]
  (loop [server (jetty/run-jetty #'handler/app {:port 3000, :join? false})]
    (if (.isStarted server)
      (do
        (f)
        (.stop server))
      (recur server))))

(defn ^:browser start-browser-fixture
  [f]
  (set-driver! {:browser :phantomjs})
  (f))

(defn ^:browser quit-browser-fixture
  [f]
  (f)
  (quit))

(use-fixtures :once start-app-server)
(use-fixtures :each start-browser-fixture quit-browser-fixture)
