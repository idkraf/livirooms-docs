<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyPaymentPlanEntry extends Model
{
    protected $fillable = [
        'property_payment_plan_id',
        'date',
        'amount',
    ];

    public function paymentPlan(): BelongsTo
    {
        return $this->belongsTo(PropertyPaymentPlan::class, 'property_payment_plan_id');
    }
}
