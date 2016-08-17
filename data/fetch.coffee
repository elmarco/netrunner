fs = require('fs')
exec = require('child_process').exec
request = require('request')
mongoskin = require('mongoskin')
mkdirp = require('mkdirp')
path = require('path')
async = require('async')

mongoUser = process.env.OPENSHIFT_MONGODB_DB_USERNAME
mongoPassword = process.env.OPENSHIFT_MONGODB_DB_PASSWORD
login = if process.env.OPENSHIFT_MONGODB_DB_PASSWORD then "#{mongoUser}:#{mongoPassword}@" else ""
mongoHost = process.env.OPENSHIFT_MONGODB_DB_HOST || '127.0.0.1'
mongoPort = process.env.OPENSHIFT_MONGODB_DB_PORT || '27017'
appName = process.env.OPENSHIFT_APP_NAME || 'conquest'

db = mongoskin.db("mongodb://#{login}#{mongoHost}:#{mongoPort}/#{appName}")

setFields = [
  "name",
  "code",
  "cycle_code"
  "date_release"
]

cardFields = [
  "area_effect",
  "atk",
  "bloodied_atk",
  "bloodied_hp",
  "card_bonus",
  "cmd",
  "code",
  "faction_code",
  "flavor",
  "hp",
  "illustrator",
  "keywords",
  "loyal",
  "pack_code",
  "planet_symbols",
  "position",
  "quantity",
  "resource_bonus",
  "shields",
  "signed",
  "starting_cards",
  "starting_resources",
  "text",
  "title",
  "traits",
  "type_code",
  "unique"
]

baseurl = "https://raw.githubusercontent.com/elmarco/conquest-cards-json/master/"

selectFields = (fields, objectList) ->
  ((fields.reduce ((newObj, key) -> newObj[key] = obj[key] if typeof(obj[key]) isnt "undefined"; obj.cost = 0 if obj.cost is "X"; newObj), {}) for obj in objectList)

fetchSets = (callback) ->
  request.get baseurl + "packs.json", (error, response, body) ->
    if !error and response.statusCode is 200
      sets = selectFields(setFields, JSON.parse(body))
      db.collection("packs").remove ->
      db.collection("packs").insert sets, (err, result) ->
        console.log("#{sets.length} sets fetched")
        callback(null, sets.length)
    else
      console.log("Fetch error: #{error}")

fetchImg = (code, imgPath, t) ->
  setTimeout ->
    console.log code
    url = "http://netrunnerdb.com/bundles/netrunnerdbcards/images/cards/en/#{code}.png"
    request(url).pipe(fs.createWriteStream(imgPath))
  , t

fetchCards = (callback) ->
  request.get baseurl + "pack/core.json", (error, response, body) ->
    if !error and response.statusCode is 200
      cards = selectFields(cardFields, JSON.parse(body))
      db.collection("cards").remove ->
      db.collection("cards").insert cards, (err, result) ->
        callback(null, cards.length)
        console.log("#{cards.length} cards fetched")

async.parallel [fetchSets, fetchCards], (error, results) ->
  db.close()
