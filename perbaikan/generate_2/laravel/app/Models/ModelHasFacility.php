<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class ModelHasFacility extends Model
{
    protected $table = 'model_has_facilities';

    public $timestamps = true;

    protected $fillable = [
        'facility_id',
        'model_type',
        'model_id',
        'is_available',
        'badge',
        'sort_order',
    ];

    protected $casts = [
        'is_available' => 'boolean',
    ];

    public function facility(): BelongsTo
    {
        return $this->belongsTo(Facility::class);
    }

    public function model(): MorphTo
    {
        return $this->morphTo();
    }
}
