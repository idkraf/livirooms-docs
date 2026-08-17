<?php

namespace Database\Seeders;

use App\Models\Property;
use Illuminate\Database\Seeder;

class PropertyPaymentPlanSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            ['name' => 'Cicilan Bulanan', 'cadence' => 'monthly', 'installments' => 12, 'total' => 12000000],
            ['name' => 'Cicilan Mingguan', 'cadence' => 'weekly', 'installments' => 52, 'total' => 12000000],
        ];

        Property::all()->each(function ($property) use ($defaults) {
            foreach ($defaults as $index => $planData) {
                $plan = \App\Models\PropertyPaymentPlan::create([
                    'property_id' => $property->id,
                    ...$planData,
                    'sort_order' => $index,
                ]);

                $installmentAmount = (float) ($planData['total'] / $planData['installments']);
                for ($i = 1; $i <= $planData['installments']; $i++) {
                    \App\Models\PropertyPaymentPlanEntry::create([
                        'property_payment_plan_id' => $plan->id,
                        'date' => now()->addMonths($i)->format('Y-m-d'),
                        'amount' => round($installmentAmount, 2),
                    ]);
                }
            }
        });
    }
}
