function beautify(presetPath) {
	return presetPath.replace("/presets/", "").replace(".json", "");
}

angular.module('beamng.apps')

.directive('sirenmodpresets', ['logger', function (logger) {
	return {
		templateUrl: '/ui/modules/apps/Sirenmod-Presets/app.html',
		replace: true,
		restrict: 'EA',
		scope: true,
		controller: function ($scope, $element, $attrs) {
				var lastSelected;
	
				function updatePresets() {
					// Get the presets list
					bngApi.engineLua("FS:findFilesByRootPattern('presets', '*.json', -1, true, false)", (data) => {
						console.log(data)
						const presetsList = document.getElementById("presets-list");
						presetsList.innerHTML = "";
						for (let i = 0; i < data.length; i++) {
							let presetPath = data[i];
							let node = document.createElement("li");
							node.preset = presetPath;
							node.onclick = function() { select(this) };			
							let textNode = document.createTextNode(beautify(presetPath));
							node.appendChild(textNode);			
							presetsList.appendChild(node);
						}
					});
				}
				
				$scope.init = function() {
					updatePresets();
				};

				select = function(element) {
					element.classList.add("selected");
					if (lastSelected) lastSelected.classList.remove("selected");
					setTimeout(
						function() {
							element.classList.remove("selected");
					}, 250);
					lastSelected = element;
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("configManagerVE.loadPreset('` + element.preset + `')")
						end
					`);
				};

				$scope.refresh = function() {
					updatePresets();
				}

				$scope.save = function(configPath) {
					if (lastSelected) {
						bngApi.engineLua(`
							local veh = be:getPlayerVehicle(0)
							if veh then
								veh:queueLuaCommand("configManagerVE.saveConfig('` + lastSelected.preset + `')")
							end
						`);
					}
				}
		}
	}
}])