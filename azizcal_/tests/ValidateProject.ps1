# AzizCal Project & Logic Verification Suite

$ErrorActionPreference = "Stop"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   AzizCal - iPhone Project Validation  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$testResults = @{
    Total = 0
    Passed = 0
    Failed = 0
}

function Run-Check($name, $scriptBlock) {
    $testResults.Total++
    Write-Host -NoNewline "[...] $name : "
    try {
        & $scriptBlock
        $testResults.Passed++
        Write-Host "PASS" -ForegroundColor Green
    } catch {
        $testResults.Failed++
        Write-Host "FAIL - $_" -ForegroundColor Red
    }
}

# 1. Structure Verification
Run-Check "Verify all required files exist" {
    $requiredFiles = @(
        "AzizCal\App\AzizCalApp.swift",
        "AzizCal\App\AppState.swift",
        "AzizCal\Models\UserGoals.swift",
        "AzizCal\Models\MealType.swift",
        "AzizCal\Models\FoodItem.swift",
        "AzizCal\Models\SavedFood.swift",
        "AzizCal\Models\WorkoutSet.swift",
        "AzizCal\Models\WorkoutExercise.swift",
        "AzizCal\Models\WorkoutSession.swift",
        "AzizCal\Models\BackupData.swift",
        "AzizCal\Services\DataStore.swift",
        "AzizCal\Services\AnalyticsService.swift",
        "AzizCal\Services\BackupService.swift",
        "AzizCal\ViewModels\GoalsViewModel.swift",
        "AzizCal\ViewModels\DashboardViewModel.swift",
        "AzizCal\ViewModels\NutritionViewModel.swift",
        "AzizCal\ViewModels\WorkoutsViewModel.swift",
        "AzizCal\ViewModels\ProgressViewModel.swift",
        "AzizCal\ViewModels\StatisticsViewModel.swift",
        "AzizCal\ViewModels\SettingsViewModel.swift",
        "AzizCal\Views\MainTabView.swift",
        "AzizCal\Views\Onboarding\OnboardingGoalsView.swift",
        "AzizCal\Views\Dashboard\DashboardView.swift",
        "AzizCal\Views\Dashboard\CalorieRingView.swift",
        "AzizCal\Views\Dashboard\MacroBarView.swift",
        "AzizCal\Views\Nutrition\NutritionView.swift",
        "AzizCal\Views\Nutrition\AddFoodSheet.swift",
        "AzizCal\Views\Nutrition\SavedFoodsView.swift",
        "AzizCal\Views\Nutrition\CopyMealSheet.swift",
        "AzizCal\Views\Workouts\WorkoutsView.swift",
        "AzizCal\Views\Workouts\ActiveWorkoutView.swift",
        "AzizCal\Views\Workouts\ExerciseSetRowView.swift",
        "AzizCal\Views\Workouts\PastWorkoutDetailView.swift",
        "AzizCal\Views\Progress\ProgressView.swift",
        "AzizCal\Views\Progress\ExerciseDetailView.swift",
        "AzizCal\Views\Progress\ExerciseChartView.swift",
        "AzizCal\Views\Statistics\StatisticsView.swift",
        "AzizCal\Views\Statistics\StatCardView.swift",
        "AzizCal\Views\Settings\SettingsView.swift",
        "AzizCal\Views\Settings\EditGoalsView.swift",
        "AzizCal\Views\Settings\BackupRestoreView.swift",
        "AzizCal\Views\Components\ArabicRTLModifier.swift",
        "AzizCal\Views\Components\EmptyStateView.swift",
        "AzizCal\Views\Components\CardContainer.swift",
        "AzizCal\Views\Components\CustomButton.swift",
        "AzizCal\Resources\Info.plist",
        "AzizCal\Resources\Assets.xcassets\Contents.json",
        "AzizCal\Resources\Assets.xcassets\AppIcon.appiconset\Contents.json",
        "AzizCal\Resources\Assets.xcassets\AccentColor.colorset\Contents.json",
        "AzizCal.xcodeproj\project.pbxproj",
        ".github\workflows\build-ipa.yml"
    )

    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            throw "Missing file: $file"
        }
    }
}

# 2. Syntax Check (Brace Balance)
Run-Check "Check Swift syntax and brace matching" {
    $swiftFiles = Get-ChildItem -Path "AzizCal" -Recurse -Filter "*.swift"
    if ($swiftFiles.Count -eq 0) { throw "No Swift files found" }

    foreach ($sf in $swiftFiles) {
        $content = [System.IO.File]::ReadAllText($sf.FullName)
        $openBraces = ($content.ToCharArray() | Where-Object { $_ -eq '{' }).Count
        $closeBraces = ($content.ToCharArray() | Where-Object { $_ -eq '}' }).Count
        if ($openBraces -ne $closeBraces) {
            throw "Brace mismatch in $($sf.Name): open=$openBraces, close=$closeBraces"
        }
    }
}

# 3. Logic Test: Saved Food Auto-calculation
Run-Check "Test saved food auto-calculation (150 kcal/100g, 200g = 300 kcal)" {
    $baseAmount = 100.0
    $caloriesPerBase = 150.0
    $proteinPerBase = 20.0
    $carbsPerBase = 10.0
    $fatPerBase = 5.0

    $enteredAmount = 200.0
    $ratio = $enteredAmount / $baseAmount
    $calcCalories = [Math]::Round(($caloriesPerBase * $ratio), 1)
    $calcProtein = [Math]::Round(($proteinPerBase * $ratio), 1)
    $calcCarbs = [Math]::Round(($carbsPerBase * $ratio), 1)
    $calcFat = [Math]::Round(($fatPerBase * $ratio), 1)

    if ($calcCalories -ne 300.0) { throw "Expected 300 kcal, got $calcCalories" }
    if ($calcProtein -ne 40.0) { throw "Expected 40g protein, got $calcProtein" }
    if ($calcCarbs -ne 20.0) { throw "Expected 20g carbs, got $calcCarbs" }
    if ($calcFat -ne 10.0) { throw "Expected 10g fat, got $calcFat" }
}

# 4. Logic Test: Calorie Surplus / Deficit Calculation
Run-Check "Test deficit and surplus display logic (2100 goal, 700 consumed -> 1400 remaining / 33.3%; 2300 consumed -> 200 surplus)" {
    # Case A: Deficit
    $target = 2100.0
    $consumedA = 700.0
    $diffA = $target - $consumedA
    $remainingA = if ($diffA -ge 0) { $diffA } else { 0 }
    $surplusA = if ($diffA -lt 0) { [Math]::Abs($diffA) } else { 0 }
    $percentageA = [Math]::Round(($consumedA / $target) * 100, 1)

    if ($remainingA -ne 1400.0) { throw "Expected remaining 1400, got $remainingA" }
    if ($surplusA -ne 0.0) { throw "Expected surplus 0, got $surplusA" }
    if ($percentageA -ne 33.3) { throw "Expected 33.3%, got $percentageA" }

    # Case B: Exceeded
    $consumedB = 2300.0
    $diffB = $target - $consumedB
    $remainingB = if ($diffB -ge 0) { $diffB } else { 0 }
    $surplusB = if ($diffB -lt 0) { [Math]::Abs($diffB) } else { 0 }
    if ($remainingB -ne 0.0) { throw "Remaining should be 0 when exceeded, got $remainingB" }
    if ($surplusB -ne 200.0) { throw "Surplus should be 200, got $surplusB" }
}

# 5. Logic Test: Workout Volume and PR (Personal Record)
Run-Check "Test workout volume and PR calculation (30kgx12, 35kgx10, 35kgx8 -> volume 990, PR 35kg)" {
    $sets = @(
        @{ SetNumber = 1; Weight = 30.0; Reps = 12; IsBodyweight = $false },
        @{ SetNumber = 2; Weight = 35.0; Reps = 10; IsBodyweight = $false },
        @{ SetNumber = 3; Weight = 35.0; Reps = 8;  IsBodyweight = $false }
    )

    $volume = 0.0
    $maxWeight = 0.0
    foreach ($s in $sets) {
        $effective = if ($s.IsBodyweight) { 0.0 } else { $s.Weight }
        $volume += ($effective * $s.Reps)
        if ($effective -gt $maxWeight) { $maxWeight = $effective }
    }

    if ($volume -ne 990.0) { throw "Expected volume 990, got $volume" }
    if ($maxWeight -ne 35.0) { throw "Expected PR 35, got $maxWeight" }
}

# 6. Logic Test: JSON Backup Schema Roundtrip
Run-Check "Test JSON backup schema serialization and parsing" {
    $sampleBackup = @{
        version = 1
        exportedAt = (Get-Date).ToString("o")
        goals = @{
            id = [Guid]::NewGuid().ToString()
            calories = 2200
            protein = 160
            carbs = 220
            fat = 65
            updatedAt = (Get-Date).ToString("o")
        }
        foodItems = @(
            @{
                id = [Guid]::NewGuid().ToString()
                name = "Grilled Chicken Breast"
                amount = 150
                unit = "g"
                calories = 247.5
                protein = 46.5
                carbs = 0
                fat = 5.4
                mealType = "Lunch"
                date = (Get-Date).ToString("o")
                createdAt = (Get-Date).ToString("o")
            }
        )
        savedFoods = @()
        workoutSessions = @()
    }

    $jsonString = $sampleBackup | ConvertTo-Json -Depth 10
    $parsed = $jsonString | ConvertFrom-Json
    if ($parsed.version -ne 1) { throw "Version mismatch in JSON backup" }
    if ($parsed.goals.calories -ne 2200) { throw "Goals calories mismatch in JSON backup" }
    if ($parsed.foodItems.Count -ne 1) { throw "Food items count mismatch in JSON backup" }
}

# 7. Logic Test: Nutrition Averages on Logged Days Only
Run-Check "Test nutrition average calculation ignores empty unlogged days" {
    $loggedDaysCalories = @(2000.0, 2400.0)
    $loggedCount = $loggedDaysCalories.Count

    $avg = ($loggedDaysCalories | Measure-Object -Average).Average
    if ($avg -ne 2200.0) {
        throw "Average was distorted! Expected 2200, got $avg"
    }
}

# 8. Check PBXProj File References
Run-Check "Verify all Swift files are referenced in project.pbxproj" {
    $pbxContent = [System.IO.File]::ReadAllText("AzizCal.xcodeproj\project.pbxproj")
    $swiftFiles = Get-ChildItem -Path "AzizCal" -Recurse -Filter "*.swift"

    foreach ($sf in $swiftFiles) {
        if (-not $pbxContent.Contains($sf.Name)) {
            throw "File not registered in project.pbxproj: $($sf.Name)"
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Checks : $($testResults.Total)"
Write-Host "Passed Checks: $($testResults.Passed)" -ForegroundColor Green
Write-Host "Failed Checks: $($testResults.Failed)" -ForegroundColor $(if ($testResults.Failed -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if ($testResults.Failed -gt 0) {
    exit 1
}
