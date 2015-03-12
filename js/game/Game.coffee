define (require) ->
    
    LoadingScene = require 'cs!game/scenes/LoadingScene'
    PlayScene = require 'cs!game/scenes/PlayScene'
    Keyboard = require 'cs!game/Keyboard'
    
    class Game
        # Constructeur
        constructor: (config) ->
            
            # Création des propriétés
            @config = config
            @canvas = document.getElementById('canvas')
            @ctx = @canvas.getContext('2d')
            
            # Images, sons, etc.
            @assets = {}
            
            # Représentation du clavier
            @keyboard = new Keyboard
            
            # Scenes
            @scenes =
                loading: new LoadingScene(this)
                play: new PlayScene(this)
            
            # Scene actuelle
            @scene = @scenes.loading
        
        # Démarrer le jeu
        start: ->
            # Application des écouteurs
            window.addEventListener('keydown', (e) => @handleKeyDown(e))
            window.addEventListener('keyup', (e) => @handleKeyUp(e))
            
            # File de chargement des assets
            loadQueue = new createjs.LoadQueue()
            loadQueue.loadManifest(@config.assetsManifest, false, @config.assetsBasePath)

            # A la fin du chargement, lancer le jeu
            loadQueue.on "complete", => @scenes.loading.handleComplete()
            loadQueue.on "progress", => @scenes.loading.handleProgress()
            loadQueue.on "fileload", (e) =>
                @assets[e.item.id] = e.result
                @scenes.loading.handleFileLoad(e)

            # Lancement du chargement
            @scenes.loading.handleStart()
            loadQueue.load()
            
            # Création du ticker
            dt = 0
            lastTime = (new Date).getTime()
            anim = =>
                now = (new Date).getTime()
                dt = now - lastTime
                lastTime = now
                @handleUpdate(dt/1000)
                window.requestAnimationFrame anim
            
            window.requestAnimationFrame anim
            
        
        # Mise à jour du jeu puis de l'affichage
        handleUpdate: (dt) ->
            @scene.handleUpdate(dt)
            @scene.handleDraw(@ctx)
        
        # Lors de l'appui sur une touche
        handleKeyDown: (event) ->
            event.preventDefault() if event.keyCode < 100
            @keyboard.keys[event.keyCode] = true
            @scene.handleKeyDown(event)

        # Lors du relâchement d'une touche
        handleKeyUp: (event) ->
            @keyboard.keys[event.keyCode] = false
            @scene.handleKeyUp(event)
        
        # Changer de scène
        switchToScene: (scene) ->
            @scene.handleStop =>
                @scene = scene
                @scene.handleStart()