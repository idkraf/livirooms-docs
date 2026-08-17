<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PropertyPaymentPlan extends Model
{
    protected $fillable = [
        'property_id',
        'name',
        'cadence',
        'installments',
        'total',
        'sort_order',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function entries(): HasMany
    {
        return $this->hasMany(PropertyPaymentPlanEntry::class);
    }
}
