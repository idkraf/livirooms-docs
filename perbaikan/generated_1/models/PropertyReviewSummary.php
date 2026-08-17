<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PropertyReviewSummary extends Model
{
    protected $fillable = [
        'property_id',
        'average',
        'total',
        'label',
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function breakdowns(): HasMany
    {
        return $this->hasMany(PropertyReviewBreakdown::class);
    }
}
