(ns play-by-play.homepage-test
  (:require [clojure.test :refer :all]
            [clj-webdriver.taxi :refer :all]
            [ring.adapter.jetty :as jetty :only [run-jetty]]
            [play-by-play.app-server.handler :as handler :only [app]]))

(deftest ^:browser home-page
  (testing "view"
    (to "http://0.0.0.0:3000/")
    (println (html "body"))
    (is (and
      (exists? ".container")
      (= "New Orleans" (text ".game-score .home .team-name"))))))

(defn ^:browser start-app-server [f]
  (loop [server (jetty/run-jetty 'handler/app {:port 3000, :join? false})]
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

