local update_testVersions = {--{version = 100, files = {toAdd = {}, toUpdate = {}, toRemove = {}}, description = "example", new = "example"}
    {version = 100, files = {{}, {}, {}}, description = "First public relase", new = "That's the first version of the update_test library.\nFor more informations please visit\nhttps://forum.mtasa.com/topic/112574-show-update_test-library"},
}

function getupdate_testVersions()
    return update_testVersions
end