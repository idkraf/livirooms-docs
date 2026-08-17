<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyReviewBreakdown extends Model
{
    protected $fillable = [
        'property_review_summary_id',
        'rating',
        'count',
    ];

    public function reviewSummary(): BelongsTo
    {
        return $this->belongsTo(PropertyReviewSummary::class, 'property_review_summary_id');
    }
}
