function beautify(presetPath) {
	return presetPath.replace("/presets/", "").replace(".json", "");
}

angular.module('beamng.apps')

.directive('sirenmodselector', [function (logger) {
	return {
		templateUrl: '/ui/modules/apps/Sirenmod-Selector/app.html',
		replace: true,
		restrict: 'EA',
		scope: true,
		controller: function ($scope, $element, $attrs) {
				var vm = this;
				vm.horn;
				
				$scope.sirenHold = function(value) {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.sirenHold(` + value + `)")
						end
					`);
				};

				$scope.sirenToggle = function() {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.sirenToggle()")
						end
					`);
				};
				
				$scope.rumblerHold = function(value, rumbler) {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.rumblerHold(` + value + `, 0, ` + rumbler + `)")
						end
					`);
				};
				
				$scope.rumblerToggle = function(rumbler) {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.rumblerToggle(0, 0, ` + rumbler + `)")
						end
					`);
				};
				
				$scope.warningHold = function(value) {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.warningHold(` + value + `)")
						end
					`);
				};

				$scope.warningToggle = function() {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.warningToggle()")
						end
					`);
				};
				
				$scope.hornHold = function(value) {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.policeHorn(` + value + `)")
						end
					`);
				};
				
				$scope.chaseMode = function() {
					bngApi.engineLua(`
						local veh = be:getPlayerVehicle(0)
						if veh then
							veh:queueLuaCommand("sirenmodVE.chaseMode()")
						end
					`);
				};
				
				$scope.$on('updateSirenmodApp', function (event, data) {
					for (const [soundName, value] of Object.entries(data)) {
						let element = document.getElementById(soundName);
						if (value) {
							element.classList.add("enabled");
						} else {
							element.classList.remove("enabled");
						}
					}
					var buttons = document.getElementsByClassName("toggle-buttons");
					if (data.sChaseMode) {
						for (let i = 0; i < buttons.length; i++) buttons[i].disabled = false;
					} else {
						for (let i = 0; i < buttons.length; i++) buttons[i].disabled = true;
					}
				});
				
				$scope.init = function() {
					console.log("init");
				};
		}
	}
}]);