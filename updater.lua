local mainURL = "https://raw.githubusercontent.com/xiRocKyz/update_test/master/"

function update_testCheckForUpdate(successCallback, faillCallback)
    fetchRemote(mainURL.."versions.lua", function(data, error)
        if error == 0 then
            local currentVersions = getupdate_testVersions()
            local versions = loadstring("return "..data:match("{.+}"))()
            successCallback(versions[#versions].version > currentVersions[#currentVersions].version, versions)
        else
            failCallback(error)
        end
    end)
end

function update_testGetUpdateData(data)
    local index = #getupdate_testVersions()+1
    local convertedData = {toAdd = {}, toUpdate = {["meta.xml"] = true, ["versions.lua"] = true}, toRemove = {}}
    local convertedIndex = {}
    while data[index] do
        for key, value in ipairs(data[index].files) do
            local key = (key == 1 and "toAdd" or (key == 2 and "toUpdate")) or "toRemove"
            for _, value in ipairs(value) do
                if key ~= "toAdd" then
                    if key == "toUpdate" then
                        if not convertedData["toAdd"][value] then
                            convertedData[key][value] = true
                        end
                    else
                        if convertedData["toAdd"][value] then
                            convertedData["toAdd"][value] = nil
                        elseif convertedData["toUpdate"][value] then
                            convertedData[key][value] = true
                            convertedData["toUpdate"][value] = nil
                        else
                            convertedData[key][value] = true
                        end
                    end
                else
                    convertedData[key][value] = true
                end
            end
        end
        index = index+1
    end
    for key, value in pairs(convertedData) do
        convertedIndex[key] = {}
        for value in pairs(value) do
            table.insert(convertedIndex[key], value)
        end
    end
    return convertedIndex
end

function update_testUpdate(updateData, key, index)
    local key = key or "toAdd"
    local index = index or 1
    if index == 1 then
        outputDebugString("[update_test] Preparing to "..((key == "toAdd" and "add files" or (key == "toUpdate" and "update files")) or "remove files").." ["..#updateData[key].." files] !")
    end
    setTimer(function(updateData, key, index)
        if updateData[key][index] then
            if key ~= "toRemove" then
                fetchRemote(mainURL..updateData[key][index], function(data, error, updateData, key, index)
                    if error == 0 then
                        if key == "toUpdate" then
                            fileDelete(updateData[key][index])
                        end
                        local file = fileCreate(updateData[key][index])
                        if file then
                            fileWrite(file, data)
                            fileClose(file)
                        end
                        outputDebugString("[update_test] Successfully "..(key == "toAdd" and "added" or (key == "toUpdate" and "updated")).." ["..updateData[key][index].."] ("..index.."/"..#updateData[key]..")")
                        update_testUpdate(updateData, key, index+1)
					else
						outputDebugString("[update_test] An error has occurred", 1)
					end
				end, "", false, updateData, key, index)
			else
                if fileExists(updateData[key][index]) then
                    fileDelete(updateData[key][index])
                    outputDebugString("[update_test] Successfully removed ["..updateData[key][index].."] ("..index.."/"..#updateData[key]..")")
                    update_testUpdate(updateData, key, index+1)
				else
					outputDebugString("[update_test] An error has occurred", 1)
				end
			end
        else
            local next = (key == "toAdd" and "toUpdate" or (key == "toUpdate" and "toRemove"))
            outputDebugString("[update_test] Successfully "..((key == "toAdd" and "added" or (key == "toUpdate" and "updated")) or "removed").." all the files")
            if next then
                update_testUpdate(updateData, next, 1)
            else
                outputDebugString("[update_test] Successfully completed the update")
                outputDebugString("[update_test] Please restart the resource")
            end
        end
    end, 1000, 1, updateData, key, index)
end

addCommandHandler("updatetest", function()
    update_testCheckForUpdate(function(success, data)
        if success then
            update_testUpdate(update_testGetUpdateData(data))
        else
            outputDebugString("You're at the latest version")
        end
    end)
end)