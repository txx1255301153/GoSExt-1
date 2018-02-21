
class "__gsoCallbacks"

function __gsoCallbacks:__init()
    self._tick          = {}
    self._draw          = {}
    self._wndMsg        = {}
    self._aaSpeed       = function() return myHero.attackSpeed end
    self._champMenu     = function() return 0 end
    self._bonusDmg      = function() return 0 end
    self._bonusDmgUnit  = function() return 0 end
    self._onTick        = function() return 0 end
    self._mousePos      = function() return nil end
    self._canMove       = function(target) return true end
    self._canAttack     = function(target) return true end
    self._onMove        = function(target) return 0 end
    self._onAttack      = function(target) return 0 end
end
function __gsoCallbacks:_setTick(func) self._tick[#self._tick+1] = func end
function __gsoCallbacks:_setDraw(func) self._draw[#self._draw+1] = func end
function __gsoCallbacks:_setWndMsg(func) self._wndMsg[#self._wndMsg+1] = func end
function __gsoCallbacks:_setAASpeed(func) self._aaSpeed = func end
function __gsoCallbacks:_setChampMenu(func) self._champMenu = func end
function __gsoCallbacks:_setBonusDmg(func) self._bonusDmg = func end
function __gsoCallbacks:_setBonusDmgUnit(func) self._bonusDmgUnit = func end
function __gsoCallbacks:_setOnTick(func) self._onTick = func end
function __gsoCallbacks:_setMousePos(func) self._mousePos = func end
function __gsoCallbacks:_setCanMove(func) self._canMove = func end
function __gsoCallbacks:_setCanAttack(func) self._canAttack = func end
function __gsoCallbacks:_setOnMove(func) self._onMove = func end
function __gsoCallbacks:_setOnAttack(func) self._onAttack = func end