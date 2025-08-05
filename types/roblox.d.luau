--!nocheck

declare class PlayersService
    GetPlayers: (PlayersService) -> {Player}
end

declare class Player
    _data: {
        Level: number,
        Coins: number,
    }
    leaderstats: Folder?
    GetAttribute: (Player, string) -> any
    SetAttribute: (Player, string, any) -> ()
end

declare class Folder end

declare class Workspace end

declare class ReplicatedStorage end

declare class ServerStorage end
declare class RBXScriptConnection
    Disconnect: (RBXScriptConnection) -> ()
end

declare global game: any

declare global workspace: Workspace

declare global Players: PlayersService

declare global ReplicatedStorage: ReplicatedStorage

declare global ServerStorage: ServerStorage
