namespace TURBU.RM2k3.RTPConverter

import System
import System.Collections.Generic
import System.IO
import System.Linq.Enumerable
import Newtonsoft.Json.Linq
import TURBU.Meta
import TURBU.RM2K.Import.LCF

class ProjectScanner:
	private _map as JObject
	private _sprites = Dictionary[of string, string]()
	private _sounds = Dictionary[of string, string]()
	private _music = Dictionary[of string, string]()
	private _anims = Dictionary[of string, string]()
	private _monsters = Dictionary[of string, string]()
	private _battleChars = Dictionary[of string, string]()
	private _battleWeapons = Dictionary[of string, string]()
	private _backdrops = Dictionary[of string, string]()
	private _tileset = Dictionary[of string, string]()
	private _sysTiles = Dictionary[of string, string]()
	private _portraits = Dictionary[of string, string]()
	private _panoramas = Dictionary[of string, string]()
	private _titles = Dictionary[of string, string]()
	private _gameOver = Dictionary[of string, string]()
	
	[Getter(Logs)]
	private _logs = List[of string]()

	private _report as Action[of string]
	
	public def constructor(report as Action[of string]):
		basePath = Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location)
		_report = report
		_map = JObject.Parse(File.ReadAllText(Path.Combine(basePath, 'conversions.json')))
		LoadMapping(_sprites, _map['CharSet'])
		LoadMapping(_sounds, _map['Sound'])
		LoadMapping(_music, _map['Music'])
		LoadMapping(_anims, _map['Battle'])
		LoadMapping(_monsters, _map['Monster'])
		LoadMapping(_battleChars, _map['BattleCharSet'])
		LoadMapping(_battleWeapons, _map['BattleWeapon'])
		LoadMapping(_backdrops, _map['Backdrop'])
		LoadMapping(_tileset, _map['ChipSet'])
		LoadMapping(_sysTiles, _map['System'])
		LoadMapping(_portraits, _map['FaceSet'])
		LoadMapping(_panoramas, _map['Panorama'])
		LoadMapping(_titles, _map['Title'])
		LoadMapping(_gameOver, _map['GameOver'])
	
	private def LoadMapping(mapping as Dictionary[of string, string], input as JObject):
		for kvp as KeyValuePair[of string, JToken] in input:
			_sprites[kvp.Key] = kvp.Value.ToString()
	
	public def Convert(path as string, maps as (string)):
		LCFWord.Is2k3 = true
		_report('Database')
		ConvertDatabase(Path.Combine(path, 'RPG_RT.ldb'))
		_report('Map Tree')
		ConvertMaps(Path.Combine(path, 'RPG_RT.lmt'), maps)
	
	private def ConvertDatabase(filename as string):
		using fs = FileStream(filename, FileMode.Open):
			db = LDB(fs)
			for hero in db.Heroes:
				temp = hero.Sprite; hero.Sprite = temp if CheckSprite(temp, "Heroes[$(hero.ID)].Sprite")
				temp = hero.Portrait; hero.Portrait = temp if CheckSprite(temp, "Heroes[$(hero.ID)].Portrait")
			for monster in db.Monsters:
				temp = monster.Filename; monster.Filename = temp if CheckMonster(temp, "Monsters[$(monster.ID)].Filename")
			for anim in db.Animations:
				unless string.IsNullOrEmpty(anim.Filename):
					temp = anim.Filename; anim.Filename = temp if CheckAnim(temp, "Animations[$(anim.ID)].Filename")
				for timing in anim.Timing.Where({t | t.Sound is not null}):
					temp = timing.Sound.Filename; timing.Sound.Filename = temp if CheckSound(temp, "Animations[$(anim.ID)].Timing[$(timing.ID)].Sound")
			for bAnim in db.BattleAnims:
				for pose in bAnim.Poses:
					temp = pose.Filename; pose.Filename = temp if CheckBattleChar(temp, "BattleAnims[$(bAnim.ID)].Poses[$(pose.ID)].Filename")
				for weapon in bAnim.Weapons:
					temp = weapon.Filename; weapon.Filename = temp if CheckBattleWeapon(temp, "BattleAnims[$(bAnim.ID)].Weapons[$(weapon.ID)].Filename")
			for ter in db.Terrains:
				temp = ter.BattleBG; ter.BattleBG = temp if CheckBackdrop(temp, "Terrains[$(ter.ID)].BattleBG")
				unless ter.SoundEffect is null:
					temp = ter.SoundEffect.Filename; ter.SoundEffect.Filename = temp if CheckSound(temp, "Terrains[$(ter.ID)].SoundEffect")
			for tileset in db.Tilesets:
				temp = tileset.Filename; tileset.Filename = temp if CheckTileset(temp, "Tilesets[$(tileset.ID)].Filename")
			ConvertSysData(db.SysData)
			ConvertDBScripts(db.MParties, db.GlobalEvents)
		if _logs.Count > 0:
			using fs = FileStream(filename, FileMode.Create, FileAccess.Write):
				db.Save(fs)
	
	private def ConvertDBScripts(MParties as RMMonsterParty*, Globals as GlobalEvent*):
		for party in MParties:
			for page in party.Events:
				ConvertScript(page.Commands, "MonsterParties[$(party.ID)].Page[$(page.ID)]")
		for gEvent in Globals:
			ConvertScript(gEvent.Script, "GlobalEvents[$(gEvent.ID)]")
	
	private static final OPCODES = HashSet[of int]((10130, 10630, 10640, 10650, 10660, 10670, 10680, 10710, \
																	11510, 11550, 11720))
	
	private def ConvertScript(script as EventCommand*, name as string):
		for opcode in script.Where({o | OPCODES.Contains(o.Opcode)}):
			ConvertOpcode(opcode, name)
	
	private callable converterMethod(ref name as string, ID as string) as bool
	
	private def ConvertOpcode(opcode as EventCommand, name as string):
		converter as converterMethod
		caseOf opcode.Opcode:
			case 10130, 10640: converter = CheckPortrait
			case 10630, 10650: converter = CheckSprite
			case 10660, 11510: converter = CheckMusic
			case 10670, 11550: converter = CheckSound
			case 10680: converter = CheckSysTile
			case 10710: converter = CheckBackdrop
			case 11720: converter = CheckPanorama
			default: assert false
		temp = opcode.Name; opcode.Name = temp if converter(temp, name)

	private def ConvertSysData(sys as RMSystemRecord):
		temp = sys.BattleSysGraphic; sys.BattleSysGraphic = temp if CheckBackdrop(temp, "SysData.BattleSysGraphic")
		temp = sys.SystemGraphic; sys.SystemGraphic = temp if CheckSysTile(temp, "SysData.SystemGraphic")
		temp = sys.TitleScreen; sys.TitleScreen = temp if CheckTitle(temp, "SysData.TitleScreen")
		temp = sys.GameOverScreen; sys.GameOverScreen = temp if CheckGameOver(temp, "SysData.GameOverScreen")
		temp = sys.TitleMusic.Filename; sys.TitleMusic.Filename = temp if CheckMusic(temp, "SysData.TitleMusic")
		temp = sys.BattleMusic.Filename; sys.BattleMusic.Filename = temp if CheckMusic(temp, "SysData.sys.BattleMusic")
		temp = sys.VictoryMusic.Filename; sys.VictoryMusic.Filename = temp if CheckMusic(temp, "SysData.VictoryMusic")
		temp = sys.InnMusic.Filename; sys.InnMusic.Filename = temp if CheckMusic(temp, "SysData.InnMusic")
		temp = sys.BoatMusic.Filename; sys.BoatMusic.Filename = temp if CheckMusic(temp, "SysData.BoatMusic")
		temp = sys.ShipMusic.Filename; sys.ShipMusic.Filename = temp if CheckMusic(temp, "SysData.ShipMusic")
		temp = sys.GameOverMusic.Filename; sys.GameOverMusic.Filename = temp if CheckMusic(temp, "SysData.GameOverMusic")
		temp = sys.AirshipMusic.Filename; sys.AirshipMusic.Filename = temp if CheckMusic(temp, "SysData.AirshipMusic")
		temp = sys.CursorSound.Filename; sys.CursorSound.Filename = temp if CheckSound(temp, "SysData.CursorSound")
		temp = sys.AcceptSound.Filename; sys.AcceptSound.Filename = temp if CheckSound(temp, "SysData.AcceptSound")
		temp = sys.CancelSound.Filename; sys.CancelSound.Filename = temp if CheckSound(temp, "SysData.CancelSound")
		temp = sys.BuzzerSound.Filename; sys.BuzzerSound.Filename = temp if CheckSound(temp, "SysData.BuzzerSound")
		temp = sys.BattleStartSound.Filename; sys.BattleStartSound.Filename = temp if CheckSound(temp, "SysData.BattleStartSound")
		temp = sys.EscapeSound.Filename; sys.EscapeSound.Filename = temp if CheckSound(temp, "SysData.EscapeSound")
		temp = sys.EnemyAttackSound.Filename; sys.EnemyAttackSound.Filename = temp if CheckSound(temp, "SysData.EnemyAttackSound")
		temp = sys.EnemyDamageSound.Filename; sys.EnemyDamageSound.Filename = temp if CheckSound(temp, "SysData.EnemyDamageSound")
		temp = sys.AllyDamageSound.Filename; sys.AllyDamageSound.Filename = temp if CheckSound(temp, "SysData.AllyDamageSound")
		temp = sys.EvadeSound.Filename; sys.EvadeSound.Filename = temp if CheckSound(temp, "SysData.EvadeSound")
		temp = sys.EnemyDiesSound.Filename; sys.EnemyDiesSound.Filename = temp if CheckSound(temp, "SysData.EnemyDiesSound")
		temp = sys.ItemUsedSound.Filename; sys.ItemUsedSound.Filename = temp if CheckSound(temp, "SysData.ItemUsedSound")
		temp = sys.BoatGraphic; sys.BoatGraphic = temp if CheckSprite(temp, "SysData.BoatGraphic")
		temp = sys.ShipGraphic; sys.ShipGraphic = temp if CheckSprite(temp, "SysData.ShipGraphic")
		temp = sys.AirshipGraphic; sys.AirshipGraphic = temp if CheckSprite(temp, "SysData.AirshipGraphic")
	
	private def ConvertMaps(filename as string, maps as (string)):
		counter = _logs.Count
		using fs = FileStream(filename, FileMode.Open):
			mt = LMT(fs)
			for info in mt.Maps.Values:
				temp = info.BgmData.Filename; info.BgmData.Filename = temp if CheckMusic(temp, "MapTree[$(info.ID)].BGM")
				temp = info.BattleBGName; info.BattleBGName = temp if CheckBackdrop(temp, "MapTree[$(info.ID)].BattleBGName")
		if _logs.Count > counter:
			using fs = FileStream(filename, FileMode.Create, FileAccess.Write):
				mt.Save(fs)
		for map in maps:
			_report('Map $(Path.GetFileName(map))')
			ConvertMap(map, mt)
	
	private def ConvertMap(filename as string, tree as LMT):
		counter = _logs.Count
		ID = int.Parse(Path.GetFileNameWithoutExtension(filename)[-4:])
		return unless tree.Maps.ContainsKey(ID)
		mapname = tree.Maps[ID].Name
		using fs = FileStream(filename, FileMode.Open):
			map = LMU(fs)
			temp = map.PanoName; map.PanoName = temp if CheckPanorama(temp, "Map[$ID ($mapname)].PanoName")
			for mapObject in map.Events:
				for page in mapObject.Pages:
					ConvertPage(page, "Map[$ID ($mapname)].Event[$(mapObject.ID) ($(mapObject.X), $(mapObject.Y))].Page[$(page.ID)]")
		if _logs.Count > counter:
			using fs = FileStream(filename, FileMode.Create, FileAccess.Write):
				map.Save(fs)
	
	private def ConvertPage(page as EventPage, name as string):
		temp = page.GraphicFile; page.GraphicFile = temp if CheckSprite(temp, "$name.GraphicFile")
		ConvertMoveScript(page.MoveScript.MoveOrder, "$name.MoveScript")
		ConvertScript(page.Script, "$name.Script")
	
	private def ConvertMoveScript(script as MoveOpcode*, name as string):
		for op in script.Where({o | o.Code in (34, 35)}):
			if op.Code == 34:
				temp = op.Name; op.Name = temp if CheckSprite(temp, name)
			else:
				temp = op.Name; op.Name = temp if CheckSound(temp, name)
	
	private def CheckResource(ref name as string, ID as string, map as Dictionary[of string, string]) as bool:
		return false if string.IsNullOrEmpty(name)
		if map.ContainsKey(name):
			_logs.Add("$ID changed from '$name' to '$(map[name])'")
			name = map[name]
			return true
		return false
	
	private def CheckSprite(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _sprites)
	
	private def CheckSound(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _sounds)
	
	private def CheckMusic(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _music)
	
	private def CheckMonster(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _monsters)
	
	private def CheckAnim(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _anims)
	
	private def CheckBattleChar(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _battleChars)
	
	private def CheckBattleWeapon(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _battleWeapons)
	
	private def CheckBackdrop(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _backdrops)
	
	private def CheckTileset(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _tileset)
	
	private def CheckSysTile(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _sysTiles)
	
	private def CheckPortrait(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _portraits)
	
	private def CheckPanorama(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _panoramas)
	
	private def CheckTitle(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _titles)
	
	private def CheckGameOver(ref name as string, ID as string) as bool:
		return CheckResource(name, ID, _gameOver)
	
